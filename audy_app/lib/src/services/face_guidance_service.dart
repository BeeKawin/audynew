import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

enum FaceGuidanceStatus {
  unsupported,
  noFace,
  tooFar,
  notCentered,
  multipleFaces,
  ready,
}

class FaceGuidanceResult {
  const FaceGuidanceResult({required this.status, this.faceBox});

  final FaceGuidanceStatus status;
  final Rect? faceBox;

  bool get isReady => status == FaceGuidanceStatus.ready && faceBox != null;
  bool get canRetryCapture =>
      status != FaceGuidanceStatus.unsupported &&
      status != FaceGuidanceStatus.ready;
}

class FaceGuidanceService {
  FaceGuidanceService() {
    if (_isMobileSupported) {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          enableClassification: false,
          enableContours: false,
          enableLandmarks: false,
          minFaceSize: 0.12,
        ),
      );
    }
  }

  static const double _minimumFaceRatio = 0.18;
  static const double _centerToleranceRatio = 0.24;
  static const double _cropPaddingRatio = 0.32;
  static const int _targetCropWidth = 640;

  static const Map<DeviceOrientation, int> _deviceOrientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  FaceDetector? _faceDetector;

  bool get _isMobileSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isSupported => _isMobileSupported && _faceDetector != null;

  Future<FaceGuidanceResult> analyzeCameraImage({
    required CameraImage image,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  }) async {
    if (!isSupported) {
      return const FaceGuidanceResult(status: FaceGuidanceStatus.unsupported);
    }

    final inputImage = _inputImageFromCameraImage(
      image: image,
      camera: camera,
      deviceOrientation: deviceOrientation,
    );

    if (inputImage == null) {
      return const FaceGuidanceResult(status: FaceGuidanceStatus.unsupported);
    }

    try {
      final faces = await _faceDetector!.processImage(inputImage);
      return _classifyFaces(
        faces,
        Size(image.width.toDouble(), image.height.toDouble()),
      );
    } catch (e) {
      debugPrint('FaceGuidanceService: camera face detection skipped - $e');
      return const FaceGuidanceResult(status: FaceGuidanceStatus.unsupported);
    }
  }

  Future<FaceGuidanceResult> analyzeImageFile(File imageFile) async {
    if (!isSupported) {
      return const FaceGuidanceResult(status: FaceGuidanceStatus.unsupported);
    }

    try {
      final decodedImage = await _decodeImageFile(imageFile);
      if (decodedImage == null) {
        return const FaceGuidanceResult(status: FaceGuidanceStatus.unsupported);
      }

      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector!.processImage(inputImage);
      return _classifyFaces(
        faces,
        Size(decodedImage.width.toDouble(), decodedImage.height.toDouble()),
      );
    } catch (e) {
      debugPrint('FaceGuidanceService: file face detection skipped - $e');
      return const FaceGuidanceResult(status: FaceGuidanceStatus.unsupported);
    }
  }

  Future<File?> cropFaceFromFile(File imageFile, Rect faceBox) async {
    try {
      final decodedImage = await _decodeImageFile(imageFile);
      if (decodedImage == null) return null;

      final padding =
          math.max(faceBox.width, faceBox.height) * _cropPaddingRatio;
      final left = (faceBox.left - padding).floor().clamp(
        0,
        decodedImage.width,
      );
      final top = (faceBox.top - padding).floor().clamp(0, decodedImage.height);
      final right = (faceBox.right + padding).ceil().clamp(
        0,
        decodedImage.width,
      );
      final bottom = (faceBox.bottom + padding).ceil().clamp(
        0,
        decodedImage.height,
      );

      final cropWidth = right - left;
      final cropHeight = bottom - top;
      if (cropWidth <= 0 || cropHeight <= 0) return null;

      final cropped = img.copyCrop(
        decodedImage,
        x: left,
        y: top,
        width: cropWidth,
        height: cropHeight,
      );

      final resized = cropped.width > _targetCropWidth
          ? img.copyResize(cropped, width: _targetCropWidth)
          : cropped;

      final tempDir = await getTemporaryDirectory();
      final croppedFile = File(
        '${tempDir.path}/emotion_face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await croppedFile.writeAsBytes(img.encodeJpg(resized, quality: 92));
      return croppedFile;
    } catch (e) {
      debugPrint('FaceGuidanceService: face crop skipped - $e');
      return null;
    }
  }

  InputImage? _inputImageFromCameraImage({
    required CameraImage image,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  }) {
    final rotation = _inputImageRotation(
      camera: camera,
      deviceOrientation: deviceOrientation,
    );
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.length != 1) return null;

    final plane = image.planes.first;
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: plane.bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: Uint8List.fromList(plane.bytes),
      metadata: metadata,
    );
  }

  InputImageRotation? _inputImageRotation({
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  }) {
    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    }

    final orientation = _deviceOrientations[deviceOrientation];
    if (orientation == null) return null;

    final rotationCompensation =
        camera.lensDirection == CameraLensDirection.front
        ? (camera.sensorOrientation + orientation) % 360
        : (camera.sensorOrientation - orientation + 360) % 360;

    return InputImageRotationValue.fromRawValue(rotationCompensation);
  }

  FaceGuidanceResult _classifyFaces(List<Face> faces, Size imageSize) {
    if (faces.isEmpty) {
      return const FaceGuidanceResult(status: FaceGuidanceStatus.noFace);
    }

    if (faces.length > 1) {
      return const FaceGuidanceResult(status: FaceGuidanceStatus.multipleFaces);
    }

    final faceBox = faces.single.boundingBox;
    final faceRatio = math.max(
      faceBox.width / imageSize.width,
      faceBox.height / imageSize.height,
    );

    if (faceRatio < _minimumFaceRatio) {
      return FaceGuidanceResult(
        status: FaceGuidanceStatus.tooFar,
        faceBox: faceBox,
      );
    }

    final imageCenter = Offset(imageSize.width / 2, imageSize.height / 2);
    final faceCenter = faceBox.center;
    final dx = (faceCenter.dx - imageCenter.dx).abs();
    final dy = (faceCenter.dy - imageCenter.dy).abs();

    if (dx > imageSize.width * _centerToleranceRatio ||
        dy > imageSize.height * _centerToleranceRatio) {
      return FaceGuidanceResult(
        status: FaceGuidanceStatus.notCentered,
        faceBox: faceBox,
      );
    }

    return FaceGuidanceResult(
      status: FaceGuidanceStatus.ready,
      faceBox: faceBox,
    );
  }

  Future<img.Image?> _decodeImageFile(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    return img.bakeOrientation(decoded);
  }

  Future<void> dispose() async {
    await _faceDetector?.close();
    _faceDetector = null;
  }
}

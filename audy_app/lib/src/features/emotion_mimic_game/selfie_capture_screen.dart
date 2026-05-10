import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../core/emotion_character_widget.dart';
import '../../services/emotion_service.dart';
import '../../services/face_guidance_service.dart';
import '../../services/sound_service.dart';
import 'mimic_result_screen.dart';

class SelfieCaptureScreen extends StatefulWidget {
  const SelfieCaptureScreen({super.key, required this.targetEmotion});

  final String targetEmotion;

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  static const Duration _faceAnalysisInterval = Duration(milliseconds: 600);

  final FaceGuidanceService _faceGuidance = FaceGuidanceService();

  CameraController? _cameraController;
  CameraDescription? _selectedCamera;
  FaceGuidanceResult _faceGuidanceResult = const FaceGuidanceResult(
    status: FaceGuidanceStatus.unsupported,
  );
  DateTime _lastFaceAnalysis = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isCameraReady = false;
  bool _isAnalyzingFrame = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _captureHintMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _errorMessage = 'No camera found on this device.');
        }
        return;
      }

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        _selectedCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
      } else {
        _selectedCamera = cameras.first;
      }

      _cameraController = CameraController(
        _selectedCamera!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: _cameraImageFormatGroup(),
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraReady = true);
      }

      await _startFaceGuidanceStream();
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('permission') || msg.contains('denied')) {
          setState(
            () => _errorMessage =
                'Camera permission denied. Please allow camera access and try again.',
          );
        } else {
          setState(() => _errorMessage = 'Could not access camera.');
        }
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    SoundService.instance.playCameraShutter();

    setState(() {
      _isProcessing = true;
      _captureHintMessage = null;
    });

    try {
      await _stopFaceGuidanceStream();

      final image = await _cameraController!.takePicture();
      final rawFile = File(image.path);

      final preparedFile = await _prepareImageForDetection(rawFile);
      if (preparedFile == null) {
        if (mounted) {
          setState(() => _isProcessing = false);
          await _startFaceGuidanceStream();
        }
        return;
      }

      if (mounted) {
        final result = await EmotionService.detectEmotion(preparedFile);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MimicResultScreen(
                capturedImage: preparedFile,
                expectedEmotion: widget.targetEmotion,
                detectedEmotion: result.detectedEmotion,
                confidence: result.confidence,
              ),
            ),
          );
        }
      }
    } on EmotionLoadException catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Emotion detection unavailable: ${e.message}';
        });
        await _startFaceGuidanceStream();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not take photo. Try again.')),
        );
        await _startFaceGuidanceStream();
      }
    }
  }

  ImageFormatGroup? _cameraImageFormatGroup() {
    if (kIsWeb) return null;
    if (Platform.isAndroid) return ImageFormatGroup.nv21;
    if (Platform.isIOS) return ImageFormatGroup.bgra8888;
    return null;
  }

  Future<void> _startFaceGuidanceStream() async {
    final controller = _cameraController;
    if (!_faceGuidance.isSupported ||
        controller == null ||
        !controller.value.isInitialized ||
        controller.value.isStreamingImages ||
        _isProcessing) {
      return;
    }

    try {
      await controller.startImageStream(_handleCameraImage);
    } catch (e) {
      debugPrint('SelfieCaptureScreen: face guidance stream skipped - $e');
    }
  }

  Future<void> _stopFaceGuidanceStream() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        !controller.value.isStreamingImages) {
      return;
    }

    try {
      await controller.stopImageStream();
    } catch (e) {
      debugPrint('SelfieCaptureScreen: face guidance stream stop skipped - $e');
    }
  }

  Future<void> _handleCameraImage(CameraImage image) async {
    final controller = _cameraController;
    final selectedCamera = _selectedCamera;
    if (!mounted ||
        _isProcessing ||
        _isAnalyzingFrame ||
        controller == null ||
        selectedCamera == null) {
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastFaceAnalysis) < _faceAnalysisInterval) {
      return;
    }

    _lastFaceAnalysis = now;
    _isAnalyzingFrame = true;

    final result = await _faceGuidance.analyzeCameraImage(
      image: image,
      camera: selectedCamera,
      deviceOrientation: controller.value.deviceOrientation,
    );

    if (mounted && !_isProcessing) {
      setState(() {
        _faceGuidanceResult = result;
        _captureHintMessage = null;
      });
    }

    _isAnalyzingFrame = false;
  }

  Future<File?> _prepareImageForDetection(File rawFile) async {
    final faceResult = await _faceGuidance.analyzeImageFile(rawFile);

    if (faceResult.isReady) {
      final croppedFile = await _faceGuidance.cropFaceFromFile(
        rawFile,
        faceResult.faceBox!,
      );
      return croppedFile ?? _compressImage(rawFile);
    }

    if (faceResult.canRetryCapture) {
      if (mounted) {
        setState(() {
          _faceGuidanceResult = faceResult;
          _captureHintMessage = _messageForStatus(faceResult.status);
        });
      }
      return null;
    }

    return _compressImage(rawFile);
  }

  Future<File> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 640);
      final frame = await codec.getNextFrame();
      final resizedImage = frame.image;

      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return imageFile;

      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/compressed_emotion_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await compressedFile.writeAsBytes(byteData.buffer.asUint8List());

      codec.dispose();
      resizedImage.dispose();

      return compressedFile;
    } catch (_) {
      return imageFile;
    }
  }

  @override
  void dispose() {
    unawaited(_stopFaceGuidanceStream());
    unawaited(_faceGuidance.dispose());
    unawaited(_cameraController?.dispose() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    SoundService.instance.playTap();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                  child: SizedBox(
                    width: AudySpacing.touchTargetMin,
                    height: AudySpacing.touchTargetMin,
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: AudySpacing.iconMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AudySpacing.elementGap),
            Text('Make this face', style: AudyTypography.headingMedium),
            const SizedBox(height: AudySpacing.smallGap),
            EmotionCharacterWidget(emotion: widget.targetEmotion, size: 120),
            const SizedBox(height: AudySpacing.sectionGap),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AudyColors.backgroundSoft,
                  borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
                  boxShadow: AudyShadows.cardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
                  child: _buildCameraView(),
                ),
              ),
            ),
            const SizedBox(height: AudySpacing.smallGap),
            _buildGuidanceMessage(),
            const SizedBox(height: AudySpacing.sectionGap),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AudyTypography.bodyMedium.copyWith(
                  color: AudyColors.error,
                ),
              ),
            if (_errorMessage == null) ...[
              SizedBox(
                width: double.infinity,
                height: AudySpacing.buttonHeight + 12,
                child: ElevatedButton(
                  onPressed: _isProcessing || !_isCameraReady
                      ? null
                      : _takePhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AudyColors.mintGreen,
                    foregroundColor: AudyColors.textOnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AudySpacing.radiusXLarge,
                      ),
                    ),
                    elevation: 4,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AudyColors.textOnColor,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_rounded, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'Take Photo',
                              style: AudyTypography.buttonText,
                            ),
                          ],
                        ),
                ),
              ),
            ],
            const SizedBox(height: AudySpacing.sectionGap),
          ],
        );
      },
    );
  }

  Widget _buildCameraView() {
    if (_errorMessage != null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_rounded,
              size: 80,
              color: AudyColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'Camera not available',
              style: TextStyle(fontSize: 18, color: AudyColors.textLight),
            ),
          ],
        ),
      );
    }

    if (_isCameraReady && _cameraController != null) {
      return CameraPreview(_cameraController!);
    }

    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AudyColors.skyBlue),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Requesting camera access...',
            style: TextStyle(fontSize: 18, color: AudyColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceMessage() {
    final message =
        _captureHintMessage ?? _messageForStatus(_faceGuidanceResult.status);

    if (_errorMessage != null || message == null) {
      return const SizedBox(height: 36);
    }

    final isReady =
        _faceGuidanceResult.status == FaceGuidanceStatus.ready &&
        _captureHintMessage == null;
    final color = isReady ? AudyColors.mintGreen : AudyColors.warning;

    return SizedBox(
      height: 36,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Row(
            key: ValueKey<String>(message),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.face_rounded, size: 24, color: color),
              const SizedBox(width: 8),
              Text(
                message,
                style: AudyTypography.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _messageForStatus(FaceGuidanceStatus status) {
    switch (status) {
      case FaceGuidanceStatus.unsupported:
        return null;
      case FaceGuidanceStatus.noFace:
        return 'Show your face';
      case FaceGuidanceStatus.tooFar:
        return 'Move closer';
      case FaceGuidanceStatus.notCentered:
        return 'Center your face';
      case FaceGuidanceStatus.multipleFaces:
        return 'One face only';
      case FaceGuidanceStatus.ready:
        return 'Ready';
    }
  }
}

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../core/emotion_character_widget.dart';
import '../../services/emotion_service.dart';
import '../../services/sound_service.dart';
import 'mimic_result_screen.dart';

class SelfieCaptureScreen extends StatefulWidget {
  const SelfieCaptureScreen({super.key, required this.targetEmotion});

  final String targetEmotion;

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  String? _errorMessage;

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

      CameraDescription selectedCamera;
      if (!kIsWeb && Platform.isAndroid || Platform.isIOS) {
        selectedCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
      } else {
        selectedCamera = cameras.first;
      }

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraReady = true);
      }
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

    // Play camera shutter sound
    SoundService.instance.playCameraShutter();

    setState(() => _isProcessing = true);

    try {
      final image = await _cameraController!.takePicture();
      final file = File(image.path);

      if (mounted) {
        final result = await EmotionService.detectEmotion(file);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MimicResultScreen(
                capturedImage: file,
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not take photo. Try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
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
}

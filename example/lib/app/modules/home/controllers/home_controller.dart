import 'package:ai_plugin/ai_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../views/components/pose_painter.dart';

class HomeController extends GetxController {
  final PoseDetector _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
    mode: PoseDetectionMode.stream,
    model: PoseDetectionModel.accurate,
  ));
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? customPaint;
  String? text;
  int count = 0;

  //TODO: Implement HomeController

  final AiPlugin aiPlugin = AiPlugin();

  @override
  void onInit() {
    super.onInit();

    aiPlugin.countCallback = (count) {
      this.count = count;
    };
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _canProcess = false;
    _poseDetector.close();
    super.onClose();
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      aiPlugin.pushPoseData(poses);
      customPaint = CustomPaint(painter: painter);
    } else {
      text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      customPaint = null;
    }
    _isBusy = false;
    update();
  }
}

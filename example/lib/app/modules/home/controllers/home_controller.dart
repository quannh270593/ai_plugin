import 'package:ai_plugin/ai_plugin.dart';
import 'package:ai_plugin/exercise_name.dart';
import 'package:ai_plugin/exercise_result.dart';
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

  late AiPlugin aiPlugin;

  @override
  void onInit() {
    super.onInit();
    aiPlugin = AiPlugin(
        countCallback: countCallback, adjustCameraCallback: (reslut) {});
  }

  void countCallback(ExerciseResult count) {
    this.count = count.result;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    print("canhdt on homecontroller close");
    _canProcess = false;
    _poseDetector.close();

    super.onClose();
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) {
      //print("canhdt !_canProcess");
      return;
    }
    if (_isBusy) {
      //print("canhdt !_isBusy");
      return;
    }
    _isBusy = true;

    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.inputImageData!.size,
        inputImage.inputImageData!.imageRotation,
      );
      aiPlugin.pushPoseData(poses, ExerciseName.squat);
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

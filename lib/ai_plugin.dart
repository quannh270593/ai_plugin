import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'ai_plugin_platform_interface.dart';

class AiPlugin {
  late void Function(int) countCallback;
  late void Function(int) adjustCameraCallback;

  Future<String?> getPlatformVersion() {
    return AiPluginPlatform.instance.getPlatformVersion();
  }

  ///poses will pushed real time from local
  void pushAdjustCameraData(
    List<Pose> poses,
    int x,
    int y,
    int x1,
    int y1,
    InputImageData inputImageData,
  ) {
    //print("canhdt original $x $y $x1 $y1");

    // x = translateX(x.toDouble(), inputImageData.imageRotation, inputImageData.size, inputImageData.size).round();
    // y = translateX(y.toDouble(), inputImageData.imageRotation, inputImageData.size, inputImageData.size).round();
    // x1 = translateX(x1.toDouble(), inputImageData.imageRotation, inputImageData.size, inputImageData.size).round();
    // y1 = translateX(y1.toDouble(), inputImageData.imageRotation, inputImageData.size, inputImageData.size).round();

    //print("canhdt traslated $x $y $x1 $y1");
    int percent = 0;

    ///count here
    ///fake data
    percent = Random().nextInt(100);

    ///return data to local throw callback
    adjustCameraCallback.call(percent);
  }

  ///poses will pushed real time from local
  void pushPoseData(List<Pose> poses, String action) {
    int count = 0;

    ///count here
    ///fake data
    count = Random().nextInt(1000);

    ///return data to local throw callback
    countCallback.call(count);
  }


  double translateX(
      double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x *
            size.width /
            (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);
      case InputImageRotation.rotation270deg:
        return size.width -
            x *
                size.width /
                (Platform.isIOS
                    ? absoluteImageSize.width
                    : absoluteImageSize.height);
      default:
        return x * size.width / absoluteImageSize.width;
    }
  }

  double translateY(
      double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y *
            size.height /
            (Platform.isIOS ? absoluteImageSize.height : absoluteImageSize.width);
      default:
        return y * size.height / absoluteImageSize.height;
    }
  }
}

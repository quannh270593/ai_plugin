import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'ai_plugin_platform_interface.dart';

class AiPlugin {
  late void Function(int) countCallback;
  late void Function(int) adjustCameraCallback;

  Future<String?> getPlatformVersion() {
    return AiPluginPlatform.instance.getPlatformVersion();
  }

  ///poses will pushed real time from local
  void pushAdjustCameraData(List<Pose> poses, int x, int y, int x1, int y1) {
    print("canhdt $x $y $x1 $y1");
    int percent = 0;

    ///count here
    ///fake data
    percent = Random().nextInt(100);

    ///return data to local throw callback
    adjustCameraCallback.call(percent);
  }

  ///poses will pushed real time from local
  void pushPoseData(List<Pose> poses) {
    int count = 0;

    ///count here
    ///fake data
    count = Random().nextInt(1000);

    ///return data to local throw callback
    countCallback.call(count);
  }
}

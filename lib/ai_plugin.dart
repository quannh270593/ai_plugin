import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'ai_plugin_platform_interface.dart';

class AiPlugin {
  Future<String?> getPlatformVersion() {
    return AiPluginPlatform.instance.getPlatformVersion();
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

  late void Function(int) countCallback;
}

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'ai_plugin_platform_interface.dart';

class AiPlugin {
  Future<String?> getPlatformVersion() {
    return AiPluginPlatform.instance.getPlatformVersion();
  }

  void pushPoseData(List<Pose> poses) {

    countCallback.call(111);
  }

  late void Function(int) countCallback;
}


import 'ai_plugin_platform_interface.dart';

class AiPlugin {
  Future<String?> getPlatformVersion() {
    return AiPluginPlatform.instance.getPlatformVersion();
  }
}

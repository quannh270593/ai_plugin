import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ai_plugin_platform_interface.dart';

/// An implementation of [AiPluginPlatform] that uses method channels.
class MethodChannelAiPlugin extends AiPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ai_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_plugin/ai_plugin.dart';
import 'package:ai_plugin/ai_plugin_platform_interface.dart';
import 'package:ai_plugin/ai_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAiPluginPlatform
    with MockPlatformInterfaceMixin
    implements AiPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AiPluginPlatform initialPlatform = AiPluginPlatform.instance;

  test('$MethodChannelAiPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAiPlugin>());
  });

  test('getPlatformVersion', () async {
    AiPlugin aiPlugin = AiPlugin();
    MockAiPluginPlatform fakePlatform = MockAiPluginPlatform();
    AiPluginPlatform.instance = fakePlatform;

    expect(await aiPlugin.getPlatformVersion(), '42');
  });
}

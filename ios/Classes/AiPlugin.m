#import "AiPlugin.h"
#if __has_include(<ai_plugin/ai_plugin-Swift.h>)
#import <ai_plugin/ai_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ai_plugin-Swift.h"
#endif

@implementation AiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAiPlugin registerWithRegistrar:registrar];
}
@end

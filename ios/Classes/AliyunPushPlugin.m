#import "PushPlugin.h"

@implementation AliyunPushPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"aliyun_push"
            binaryMessenger:[registrar messenger]];
  PushPlugin* instance = [[PushPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getDeviceId" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"turnOnDebug" isEqualToString:call.method]) {

  } else if ([@"bindAccount" isEqualToString:call.method]) {

  } else if ([@"unbindAccount" isEqualToString:call.method]) {

  } else if ([@"addAlias" isEqualToString:call.method]) {

  } else if ([@"removeAlias" isEqualToString:call.method]) {

  } else if ([@"listAlias" isEqualToString:call.method]) {

  } else if ([@"bindTag" isEqualToString:call.method]) {

  } else if ([@"unbindTag" isEqualToString:call.method]) {

  } else if ([@"listTags" isEqualToString:call.method]) {

  } else if ([@"showNoticeWhenForground" isEqualToString:call.method]) {

  } else if ([@"registerAPNS" isEqualToString:call.method]) {

  } else if ([@"registerDevice" isEqualToString:call.method]) {

  } else if ([@"setBadgeNum" isEqualToString:call.method]) {

  } else if ([@"syncBadgeNum" isEqualToString:call.method]) {

  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end

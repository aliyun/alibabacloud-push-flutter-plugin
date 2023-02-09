#import "AliyunPushPlugin.h"
#import <CloudPushSDK/CloudPushSDK.h>
// iOS 10 notification
#import <UserNotifications/UserNotifications.h>

@interface AliyunPushLog : NSObject

+ (void)enableLog;

+ (BOOL)isLogEnabled;

+ (void)disableLog;

#define PushLogD(frmt, ...)\
if ([AliyunPushLog isLogEnabled]) {\
NSLog(@"[CloudPush Debug]: %@", [NSString stringWithFormat:(frmt), ##__VA_ARGS__]);\
}

#define PushLogE(frmt, ...)\
if ([AliyunPushLog isLogEnabled]) {\
NSLog(@"[CloudPush Error]: %@", [NSString stringWithFormat:(frmt), ##__VA_ARGS__]);\
}

@end

static BOOL logEnable = NO;

@implementation AliyunPushLog

+ (void)enableLog {
    logEnable = YES;
}

+ (BOOL)isLogEnabled {
    return logEnable;
}

+ (void)disableLog {
    logEnable = NO;
}

@end


@interface AliyunPushPlugin () <UNUserNotificationCenterDelegate>

@end


@implementation AliyunPushPlugin {
    // iOS 10通知中心
    UNUserNotificationCenter *_notificationCenter;
    BOOL _showNoticeWhenForeground;
    NSData* _deviceToken;
}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"aliyun_push"
            binaryMessenger:[registrar messenger]];
  AliyunPushPlugin* instance = [[AliyunPushPlugin alloc] init];
    instance.channel = channel;
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

/*
 * APNs注册成功回调，将返回的deviceToken上传到CloudPush服务器
 */
- (void)application: (UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            PushLogD(@"Register deviceToken successfully, deviceToken: %@",[CloudPushSDK getApnsDeviceToken]);
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:[CloudPushSDK getApnsDeviceToken] forKey:@"apnsDeviceToken"];
            [self.channel invokeMethod:@"onRegisterDeviceTokenSuccess" arguments:dic];
        } else {
            PushLogD(@"Register deviceToken failed, error: %@", res.error);
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:res.error forKey:@"error"];
            [self.channel invokeMethod:@"onRegisterDeviceTokenFailed" arguments:dic];
        }
    }];
    PushLogD(@"####### ===> APNs register success");
}

/*
 *  APNs注册失败回调
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:error.userInfo.description forKey:@"error"];
    [self.channel invokeMethod:@"onRegisterDeviceTokenFailed" arguments:dic];
    PushLogD(@"####### ===> APNs register failed, %@", error);
}


-(void)registerAPNS {
    float systemVersionNum = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSLog(@"####### ===> systemVersion: %f", systemVersionNum);
    if (systemVersionNum >= 10.0) {
        // iOS 10 notifications
        _notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        _notificationCenter.delegate = self;
        // 请求推送权限
        [_notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // granted
                NSLog(@"####### ===> User authored notification.");
                // 向APNs注册，获取deviceToken
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            } else {
                // not granted
                NSLog(@"####### ===> User denied notification.");
            }
        }];
    } else if (systemVersionNum >= 8.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                           categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#pragma clang diagnostic pop
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#pragma clang diagnostic pop
    }
}


- (BOOL)application:(UIApplication*)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    
    // 取得APNS通知内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    // 内容
    NSString *content = [aps valueForKey:@"alert"];
    // badge数量
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue];
    // 播放声音
    NSString *sound = [aps valueForKey:@"sound"];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *extras = [userInfo valueForKey:@"Extras"]; //服务端中Extras字段，key是自己定义的
    PushLogD(@"content = [%@], badge = [%ld], sound = [%@], Extras = [%@]", content, (long)badge, sound, extras);
    
    [CloudPushSDK sendNotificationAck:userInfo];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:content forKey:@"content"];
    [dic setValue:@(badge) forKey:@"badge"];
    [dic setValue:sound forKey:@"sound"];
    [dic setValue:extras forKey:@"extras"];
    
    [self.channel invokeMethod:@"onNotification" arguments:dic];
    
    return YES;
}

- (void)handleiOS10Notification:(UNNotification *)notification {
    UNNotificationRequest *request = notification.request;
    UNNotificationContent *content = request.content;
    NSDictionary *userInfo = content.userInfo;
    // 通知时间
    NSDate *noticeDate = notification.date;
    // 标题
    NSString *title = content.title;
    // 副标题
    NSString *subtitle = content.subtitle;
    // 内容
    NSString *body = content.body;
    // 角标
    int badge = [content.badge intValue];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *extras = [userInfo valueForKey:@"Extras"];
    
    // 通知角标数清0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //  同步角标数到服务端
    [self syncBadgeNum:0 result:nil];
    
    
    // 通知打开回执上报
    [CloudPushSDK sendNotificationAck:userInfo];
    PushLogD(@"Notification, date: %@, title: %@, subtitle: %@, body: %@, badge: %d, extras: %@.", noticeDate, title, subtitle, body, badge, extras);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:noticeDate forKey:@"date"];
    [dic setValue:title forKey:@"title"];
    [dic setValue:subtitle forKey:@"subtitle"];
    [dic setValue:body forKey:@"body"];
    [dic setValue:@(badge) forKey:@"badge"];
    [dic setValue:extras forKey:@"extras"];
    
    [self.channel invokeMethod:@"onNotification" arguments:dic];
}

/*
    APP处于前台时收到通知(iOS 10+)
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    if(_showNoticeWhenForeground) {
        // 通知弹出，且带有声音、内容和角标
        completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
    } else {
        // 处理iOS 10通知，并上报通知打开回执
        [self handleiOS10Notification:notification];
        // 通知不弹出
        completionHandler(UNNotificationPresentationOptionNone);
    }
}

/**
 *  触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    NSString *userAction = response.actionIdentifier;
    // 点击通知打开
    if ([userAction isEqualToString:UNNotificationDefaultActionIdentifier]) {
        [CloudPushSDK sendNotificationAck:response.notification.request.content.userInfo];
        [self.channel invokeMethod:@"onNotificationOpened" arguments:response.notification.request.content.userInfo];
    }
    // 通知dismiss，category创建时传入UNNotificationCategoryOptionCustomDismissAction才可以触发
    if ([userAction isEqualToString:UNNotificationDismissActionIdentifier]) {
        //通知删除回执上报
        [CloudPushSDK sendDeleteNotificationAck:response.notification.request.content.userInfo];
        [self.channel invokeMethod:@"onNotificationRemoved" arguments:response.notification.request.content.userInfo];
    }
    
    completionHandler();
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"initPushSdk" isEqualToString:call.method]) {
      [self initPushSdk:call result: result];
  } else if ([@"getDeviceId" isEqualToString:call.method]) {
      [self getDeviceId:result];
  } else if ([@"turnOnDebug" isEqualToString:call.method]) {
      [self turnOnDebug];
  } else if ([@"bindAccount" isEqualToString:call.method]) {
      [self bindAccount:call result:result];
  } else if ([@"unbindAccount" isEqualToString:call.method]) {
      [self unbindAccount:result];
  } else if ([@"addAlias" isEqualToString:call.method]) {
      [self addAlias:call result:result];
  } else if ([@"removeAlias" isEqualToString:call.method]) {
      [self removeAlias:call result:result];
  } else if ([@"listAlias" isEqualToString:call.method]) {
      [self listAlias:result];
  } else if ([@"bindTag" isEqualToString:call.method]) {
      [self bindTag:call result:result];
  } else if ([@"unbindTag" isEqualToString:call.method]) {
      [self unbindTag:call result:result];
  } else if ([@"listTags" isEqualToString:call.method]) {
      [self listTags:call result:result];
  } else if ([@"showNoticeWhenForeground" isEqualToString:call.method]) {
      [self showNoticeWhenForeground:call];
  } else if ([@"registerAPNS" isEqualToString:call.method]) {
      [self registerAPNS];
  } else if ([@"setBadgeNum" isEqualToString:call.method]) {
      [self setBadgeNum:call result:result];
  } else if ([@"syncBadgeNum" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      [self syncBadgeNum:[arguments[@"badgeNum"] integerValue] result:result];
  } else if ([@"getApnsDeviceToken" isEqualToString:call.method]) {
      [self getApnsDeviceToken:result];
  } else if ([@"isChannelOpened" isEqualToString:call.method]) {
      result(@([CloudPushSDK isChannelOpened]));
  } else if ([@"setPluginLogEnabled" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      bool enabled = arguments[@"enabled"];
      if (enabled) {
        [AliyunPushLog enableLog];
      }else {
        [AliyunPushLog disableLog];
      }
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

- (void) initPushSdk:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString *appKey = arguments[@"appKey"];
    NSString *appSecret = arguments[@"appSecret"];
    
    [CloudPushSDK turnOnDebug];
    

    if (!appKey || !appKey.length) {
        result(@{KEY_CODE: CODE_PARAMS_ILLEGAL, @"errorMsg": @"appKey config error"});
        return;
    }

    if (!appSecret|| !appSecret.length) {
        result(@{KEY_CODE: CODE_PARAMS_ILLEGAL, @"errorMsg": @"appSecret config error"});
        return;
    }

    //APNS注册，获取deviceToken并上报
    @try {
        [self registerAPNS];
    } @catch (NSException *exception) {
        NSLog(@"###### CloudPush error: %@", exception.reason);
    } @finally {

    }
    
    
    //初始化
    [CloudPushSDK asyncInit:appKey appSecret:appSecret callback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
            result(@{KEY_CODE:CODE_SUCCESS});
        } else {
            NSLog(@"Push SDK init failed, error: %@", res.error);
            result(@{KEY_CODE:CODE_FAILED, @"errorMsg": res.error.userInfo});
        }
    }];
    // 监听推送通道打开动作
    [self listenerOnChannelOpened];
    [self registerMessageReceive];
}

#pragma mark Channel Opened
/**
 *    注册推送通道打开监听
 */
- (void)listenerOnChannelOpened {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChannelOpened:)
                                                 name:@"CCPDidChannelConnectedSuccess"
                                               object:nil];
}

/**
 *    推送通道打开回调
 */
- (void)onChannelOpened:(NSNotification *)notification {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [self.channel invokeMethod:@"onChannelOpened" arguments:dic];
}

#pragma mark Receive Message
/**
 *    @brief    注册推送消息到来监听
 */
- (void)registerMessageReceive {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReceived:)
                                                 name:@"CCPDidReceiveMessageNotification"
                                               object:nil];
}

/**
 *    处理到来推送消息
 */
- (void)onMessageReceived:(NSNotification *)notification {
    CCPSysMessage *message = [notification object];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:message.title forKey:@"title"];
    [dic setValue:message.body forKey:@"body"];
    [self.channel invokeMethod:@"onMessage" arguments:dic];
}

/* 设置角标个数 */
- (void) setBadgeNum:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    [UIApplication sharedApplication].applicationIconBadgeNumber = [arguments[@"badgeNum"] integerValue];
    result(@{KEY_CODE: CODE_SUCCESS});
}

/* 同步通知角标数到服务端*/
- (void) syncBadgeNum:(NSUInteger)badgeNum result: (FlutterResult)result{
    [CloudPushSDK syncBadgeNum:badgeNum withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            PushLogD(@"Sync badge num: [%lu] success.", (unsigned long)badgeNum);
            if (result) {
                result(@{KEY_CODE: CODE_SUCCESS});
            }
        } else {
            PushLogD(@"Sync badge num: [%lu] failed, error: %@", (unsigned long)badgeNum, res.error);
            if (result) {
                result(@{KEY_CODE: CODE_FAILED, @"errorMsg": res.error});
            }
        }
    }];
}

- (void) getDeviceId: (FlutterResult)result {
    result([CloudPushSDK getDeviceId]);
}

- (void) turnOnDebug {
    [CloudPushSDK turnOnDebug];
}

- (void) showNoticeWhenForeground:(FlutterMethodCall*)call  {
    NSDictionary *arguments = call.arguments;
    BOOL enable = arguments[@"enable"];
    _showNoticeWhenForeground = enable;
}

- (void) getApnsDeviceToken:(FlutterResult) result {
    result([CloudPushSDK getApnsDeviceToken]);
}

- (void) bindAccount: (FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* account = arguments[@"account"];
    if (account) {
        [CloudPushSDK bindAccount:account withCallback:^(CloudPushCallbackResult *res) {
            if (res.success) {
                result(@{KEY_CODE:CODE_SUCCESS});
            } else {
                result(@{KEY_CODE:CODE_FAILED, KEY_ERROR_MSG: res.error});
            }
        }];
    } else {
        result(@{KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: @"account can not be empty"});
    }
}

- (void) unbindAccount:(FlutterResult)result {
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        if (res.success) {
            result(@{KEY_CODE:CODE_SUCCESS});
        } else {
            result(@{KEY_CODE:CODE_FAILED, KEY_ERROR_MSG: res.error});
        }
    }];
}

- (void) addAlias:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* alias = arguments[@"alias"];
    if (alias) {
        [CloudPushSDK addAlias:alias withCallback:^(CloudPushCallbackResult *res) {
            if (res.success) {
                result(@{KEY_CODE:CODE_SUCCESS});
            } else {
                result(@{KEY_CODE:CODE_FAILED, KEY_ERROR_MSG: res.error});
            }
        }];
    } else {
        result(@{KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: @"alias can not be empty"});
    }
}

- (void) removeAlias:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    NSString* alias = arguments[@"alias"];
    if (alias) {
        [CloudPushSDK removeAlias:alias withCallback:^(CloudPushCallbackResult *res) {
            if (res.success) {
                result(@{KEY_CODE:CODE_SUCCESS});
            } else {
                result(@{KEY_CODE:CODE_FAILED, KEY_ERROR_MSG: res.error});
            }
        }];
    } else {
        result(@{KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: @"alias can not be empty"});
    }
}

- (void) listAlias:(FlutterResult)result {
    [CloudPushSDK listAliases:^(CloudPushCallbackResult *res) {
        if (res.success) {
            result(@{KEY_CODE:CODE_SUCCESS});
        } else {
            result(@{KEY_CODE:CODE_FAILED, KEY_ERROR_MSG: res.error});
        }
    }];
}

- (void) bindTag:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    
    NSArray* tags = arguments[@"tags"];
    NSString* alias = arguments[@"alias"];
    id targetObj = arguments[@"target"];
    
    if (tags && tags.count != 0) {
        int target;
        if (!targetObj) {
            target = 1;
        } else {
            target = [targetObj intValue];
        }
        [CloudPushSDK bindTag:target withTags:tags withAlias:alias withCallback:^(CloudPushCallbackResult *res){
            if (res.success) {
                result(@{KEY_CODE:CODE_SUCCESS});
            } else {
                result(@{KEY_CODE:CODE_FAILED, KEY_ERROR_MSG: res.error});
            }
        }];
    } else {
        result(@{KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: @"tags can not be empty"});
    }
}

- (void) unbindTag:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    
    NSArray* tags = arguments[@"tags"];
    NSString* alias = arguments[@"alias"];
    id targetObj = arguments[@"target"];
    
    if (tags && tags.count != 0) {
        int target;
        if (!targetObj) {
            target = 1;
        } else {
            target = [targetObj intValue];
        }
        [CloudPushSDK unbindTag:target withTags:tags withAlias:alias withCallback:^(CloudPushCallbackResult *res){
            if (res.success) {
                result(@{KEY_CODE:CODE_SUCCESS});
            } else {
                result(@{KEY_CODE:CODE_FAILED, KEY_ERROR_MSG: res.error});
            }
        }];
    } else {
        result(@{KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: @"tags can not be empty"});
    }
}

- (void) listTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    id targetObj = arguments[@"target"];
    int target;
    if (!targetObj) {
        target = 1;
    } else {
        target = [targetObj intValue];
    }
    [CloudPushSDK listTags:target withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            result(@{KEY_CODE:CODE_SUCCESS});
        } else {
            result(@{KEY_CODE:CODE_FAILED, KEY_ERROR_MSG: res.error});
        }
    }];
}



@end

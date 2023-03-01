import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kAliyunPushSuccessCode = "10000";

///参数错误
const kAliyunPushParamsIllegal = "10001";

const kAliyunPushFailedCode = "10002";

const kAliyunPushOnlyAndroid = "10003";

const kAliyunPushOnlyIOS = "10004";

///平台不支持，比如Android创建group只支持Android 8.0以上版本
const kAliyunPushNotSupport = "10005";

///LogLevel
const kAliyunPushLogLevelError = 0;
const kAliyunPushLogLevelInfo = 1;
const kAliyunPushLogLevelDebug = 2;

///本设备
const kAliyunTargetDevice = 1;

///本设备绑定账号
const kAliyunTargetAccount = 2;

///别名
const kAliyunTargetAlias = 3;

typedef PushCallback = Future<dynamic> Function(Map<dynamic, dynamic> message);

class AliyunPush {
  @visibleForTesting
  final methodChannel = const MethodChannel('aliyun_push');

  AliyunPush._internal();

  factory AliyunPush() => _instance;

  static final AliyunPush _instance = AliyunPush._internal();

  ///发出通知的回调
  PushCallback? _onNotification;

  ///应用处于前台时通知到达回调
  PushCallback? _onAndroidNotificationReceivedInApp;

  ///推送消息的回调方法
  PushCallback? _onMessage;

  ///从通知栏打开通知的扩展处理
  PushCallback? _onNotificationOpened;

  ///通知删除回调
  PushCallback? _onNotificationRemoved;

  ///无动作通知点击回调
  PushCallback? _onAndroidNotificationClickedWithNoAction;

  ///iOS通知打开回调
  PushCallback? _onIOSChannelOpened;

  ///APNs注册成功回调
  PushCallback? _onIOSRegisterDeviceTokenSuccess;

  ///APNs注册失败回调
  PushCallback? _onIOSRegisterDeviceTokenFailed;

  void addMessageReceiver(
      {PushCallback? onNotification,
      PushCallback? onMessage,
      PushCallback? onNotificationOpened,
      PushCallback? onNotificationRemoved,
      PushCallback? onAndroidNotificationReceivedInApp,
      PushCallback? onAndroidNotificationClickedWithNoAction,
      PushCallback? onIOSChannelOpened,
      PushCallback? onIOSRegisterDeviceTokenSuccess,
      PushCallback? onIOSRegisterDeviceTokenFailed}) {
    _onNotification = onNotification;
    _onAndroidNotificationReceivedInApp = onAndroidNotificationReceivedInApp;
    _onMessage = onMessage;
    _onNotificationOpened = onNotificationOpened;
    _onNotificationRemoved = onNotificationRemoved;
    _onAndroidNotificationClickedWithNoAction =
        onAndroidNotificationClickedWithNoAction;
    _onIOSChannelOpened = onIOSChannelOpened;
    _onIOSRegisterDeviceTokenSuccess = onIOSRegisterDeviceTokenSuccess;
    _onIOSRegisterDeviceTokenFailed = onIOSRegisterDeviceTokenFailed;

    methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  Future<dynamic> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onNotification':
        return _onNotification!(call.arguments.cast<dynamic, dynamic>());
      case 'onNotificationReceivedInApp':
        return _onAndroidNotificationReceivedInApp!(
            call.arguments.cast<dynamic, dynamic>());
      case 'onMessage':
        return _onMessage!(call.arguments.cast<dynamic, dynamic>());
      case 'onNotificationOpened':
        return _onNotificationOpened!(call.arguments.cast<dynamic, dynamic>());
      case 'onNotificationRemoved':
        return _onNotificationRemoved!(call.arguments.cast<dynamic, dynamic>());
      case 'onNotificationClickedWithNoAction':
        return _onAndroidNotificationClickedWithNoAction!(
            call.arguments.cast<dynamic, dynamic>());
      case 'onChannelOpened':
        return _onIOSChannelOpened!(call.arguments.cast<dynamic, dynamic>());
      case 'onRegisterDeviceTokenSuccess':
        return _onIOSRegisterDeviceTokenSuccess!(
            call.arguments.cast<dynamic, dynamic>());
      case 'onRegisterDeviceTokenFailed':
        return _onIOSRegisterDeviceTokenFailed!(
            call.arguments.cast<dynamic, dynamic>());
    }
  }

  ///注册推送
  Future<Map<dynamic, dynamic>> initPush(
      {String? appKey, String? appSecret}) async {
    if (Platform.isIOS) {
      Map<dynamic, dynamic> initResult = await methodChannel.invokeMethod(
          'initPushSdk', {'appKey': appKey, 'appSecret': appSecret});
      return initResult;
    } else {
      Map<dynamic, dynamic> initResult =
          await methodChannel.invokeMethod('initPush');
      return initResult;
    }
  }

  ///注册厂商通道
  Future<Map<dynamic, dynamic>> initAndroidThirdPush() async {
    Map<dynamic, dynamic> initResult =
        await methodChannel.invokeMethod('initThirdPush');
    return initResult;
  }

  Future<Map<dynamic, dynamic>> closeAndroidPushLog() async {
    if (!Platform.isAndroid) {
      return {
        'code': kAliyunPushOnlyAndroid,
        'errorMsg': 'Only support Android'
      };
    }
    Map<dynamic, dynamic> result =
        await methodChannel.invokeMethod('closePushLog');
    return result;
  }

  ///获取deviceId
  Future<String> getDeviceId() async {
    var deviceId = await methodChannel.invokeMethod('getDeviceId');
    return deviceId;
  }

  ///设置log的级别
  Future<Map<dynamic, dynamic>> setAndroidLogLevel(int level) async {
    if (!Platform.isAndroid) {
      return {
        'code': kAliyunPushOnlyAndroid,
        'errorMsg': 'Only support Android'
      };
    }
    Map<dynamic, dynamic> result =
        await methodChannel.invokeMethod('setLogLevel', {'level': level});
    return result;
  }

  ///绑定账号
  Future<Map<dynamic, dynamic>> bindAccount(String account) async {
    Map<dynamic, dynamic> bindResult =
        await methodChannel.invokeMethod('bindAccount', {'account': account});
    return bindResult;
  }

  ///解绑账号
  Future<Map<dynamic, dynamic>> unbindAccount() async {
    Map<dynamic, dynamic> unbindResult =
        await methodChannel.invokeMethod('unbindAccount');
    return unbindResult;
  }

  ///添加别名
  Future<Map<dynamic, dynamic>> addAlias(String alias) async {
    Map<dynamic, dynamic> addResult =
        await methodChannel.invokeMethod('addAlias', {'alias': alias});
    return addResult;
  }

  ///移除别名
  Future<Map<dynamic, dynamic>> removeAlias(String alias) async {
    Map<dynamic, dynamic> removeResult =
        await methodChannel.invokeMethod('removeAlias', {'alias': alias});
    return removeResult;
  }

  ///查询绑定别名
  Future<Map<dynamic, dynamic>> listAlias() async {
    Map<dynamic, dynamic> listResult =
        await methodChannel.invokeMethod('listAlias');
    return listResult;
  }

  ///添加标签
  ///
  /// @param tags     标签名
  /// @param target   目标类型，1: 本设备  2: 本设备绑定账号  3: 别名
  /// @param alias    别名（仅当target = 3时生效）
  Future<Map<dynamic, dynamic>> bindTag(List<String> tags,
      {int target = kAliyunTargetDevice, String? alias}) async {
    Map<dynamic, dynamic> bindResult = await methodChannel.invokeMethod(
        'bindTag', {'tags': tags, 'target': target, 'alias': alias});
    return bindResult;
  }

  ///移除标签
  ///
  /// @param tags     标签名
  /// @param target   目标类型，1: 本设备  2: 本设备绑定账号  3: 别名
  /// @param alias    别名（仅当target = 3时生效）
  Future<Map<dynamic, dynamic>> unbindTag(List<String> tags,
      {int target = kAliyunTargetDevice, String? alias}) async {
    Map<dynamic, dynamic> unbindResult = await methodChannel.invokeMethod(
        'unbindTag', {'tags': tags, 'target': target, 'alias': alias});
    return unbindResult;
  }

  /// 查询标签列表
  ///
  /// @param target   目标类型，1: 本设备
  Future<Map<dynamic, dynamic>> listTags(
      {int target = kAliyunTargetDevice}) async {
    Map<dynamic, dynamic> listResult =
        await methodChannel.invokeMethod('listTags', {'target': target});
    return listResult;
  }

  ///绑定手机号码
  Future<Map<dynamic, dynamic>> bindPhoneNumber(String phone) async {
    if (!Platform.isAndroid) {
      return {
        'code': kAliyunPushOnlyAndroid,
        'errorMsg': 'Only support Android'
      };
    }
    Map<dynamic, dynamic> bindResult =
        await methodChannel.invokeMethod('bindPhoneNumber', {'phone': phone});
    return bindResult;
  }

  ///解绑手机号码
  Future<Map<dynamic, dynamic>> unbindPhoneNumber() async {
    if (!Platform.isAndroid) {
      return {
        'code': kAliyunPushOnlyAndroid,
        'errorMsg': 'Only support Android'
      };
    }
    Map<dynamic, dynamic> unbindResult =
        await methodChannel.invokeMethod('unbindPhoneNumber');
    return unbindResult;
  }

  ///设置通知分组展示，只针对android
  ///
  ///@param inGroup 是否分组折叠展示
  Future<Map<dynamic, dynamic>> setNotificationInGroup(bool inGroup) async {
    if (!Platform.isAndroid) {
      return {
        'code': kAliyunPushOnlyAndroid,
        'errorMsg': 'Only support Android'
      };
    }
    Map<dynamic, dynamic> result = await methodChannel
        .invokeMethod('setNotificationInGroup', {'inGroup': inGroup});
    return result;
  }

  ///清除所有通知
  Future<Map<dynamic, dynamic>> clearNotifications() async {
    if (!Platform.isAndroid) {
      return {
        'code': kAliyunPushOnlyAndroid,
        'errorMsg': 'Only support Android'
      };
    }
    Map<dynamic, dynamic> result =
        await methodChannel.invokeMethod('clearNotifications');
    return result;
  }

  ///创建Android平台的NotificationChannel
  Future<Map<dynamic, dynamic>> createAndroidChannel(
      String id, String name, int importance, String description,
      {String? groupId,
      bool? allowBubbles,
      bool? light,
      int? lightColor,
      bool? showBadge,
      String? soundPath,
      int? soundUsage,
      int? soundContentType,
      int? soundFlag,
      bool? vibration,
      List<int>? vibrationPatterns}) async {
    if (!Platform.isAndroid) {
      return {
        'code': kAliyunPushOnlyAndroid,
        'errorMsg': 'Only support Android'
      };
    }
    Map<dynamic, dynamic> createResult =
        await methodChannel.invokeMethod('createChannel', {
      'id': id,
      'name': name,
      'importance': importance,
      'description': description,
      'groupId': groupId,
      'allowBubbles': allowBubbles,
      'light': light,
      'lightColor': lightColor,
      'showBadge': showBadge,
      'soundPath': soundPath,
      'soundUsage': soundUsage,
      'soundContentType': soundContentType,
      'soundFlag': soundFlag,
      'vibration': vibration,
      'vibrationPatterns': vibrationPatterns
    });
    return createResult;
  }

  ///创建通知通道的分组
  Future<Map<dynamic, dynamic>> createAndroidChannelGroup(
      String id, String name, String desc) async {
    if (!Platform.isAndroid) {
      return {
        'code': kAliyunPushOnlyAndroid,
        'errorMsg': 'Only support Android'
      };
    }
    Map<dynamic, dynamic> createResult = await methodChannel.invokeMethod(
        'createChannelGroup', {'id': id, 'name': name, 'desc': desc});
    return createResult;
  }

  ///检查通知状态
  ///
  ///@param id 通道的id
  Future<bool> isAndroidNotificationEnabled({String? id}) async {
    if (!Platform.isAndroid) {
      return false;
    }
    bool enabled =
        await methodChannel.invokeMethod('isNotificationEnabled', {'id': id});
    return enabled;
  }

  ///跳转到通知设置页面
  void jumpToAndroidNotificationSettings({String? id}) {
    if (!Platform.isAndroid) {
      return;
    }
    methodChannel.invokeMethod('jumpToNotificationSettings');
  }

  ///开启iOS的debug日志
  Future<Map<dynamic, dynamic>> turnOnIOSDebug() async {
    if (!Platform.isIOS) {
      return {'code': kAliyunPushOnlyIOS, 'errorMsg': 'Only support iOS'};
      ;
    }
    Map<dynamic, dynamic> result =
        await methodChannel.invokeMethod('turnOnDebug');
    return result;
  }

  Future<Map<dynamic, dynamic>> showIOSNoticeWhenForeground(bool enable) async {
    if (!Platform.isIOS) {
      return {'code': kAliyunPushOnlyIOS, 'errorMsg': 'Only support iOS'};
    }
    Map<dynamic, dynamic> result = await methodChannel
        .invokeMethod('showNoticeWhenForeground', {'enable': enable});
    return result;
  }

  Future<Map<dynamic, dynamic>> setIOSBadgeNum(int num) async {
    if (!Platform.isIOS) {
      return {'code': kAliyunPushOnlyIOS, 'errorMsg': 'Only support iOS'};
      ;
    }
    Map<dynamic, dynamic> result =
        await methodChannel.invokeMethod('setBadgeNum', {'badgeNum': num});
    return result;
  }

  Future<Map<dynamic, dynamic>> syncIOSBadgeNum(int num) async {
    if (!Platform.isIOS) {
      return {'code': kAliyunPushOnlyIOS, 'errorMsg': 'Only support iOS'};
    }
    Map<dynamic, dynamic> result =
        await methodChannel.invokeMethod('syncBadgeNum', {'badgeNum': num});
    return result;
  }

  Future<String> getApnsDeviceToken() async {
    if (!Platform.isIOS) {
      return 'Only support iOS';
    }
    var apnsDeviceToken =
        await methodChannel.invokeMethod('getApnsDeviceToken');
    return apnsDeviceToken;
  }

  Future<bool> isIOSChannelOpened() async {
    if (!Platform.isIOS) {
      return false;
    }
    var opened = await methodChannel.invokeMethod('isChannelOpened');
    return opened;
  }

  void setPluginLogEnabled(bool enabled) {
    methodChannel.invokeMethod('setPluginLogEnabled', {'enabled': enabled});
  }
}

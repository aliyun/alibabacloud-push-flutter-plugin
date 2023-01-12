import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';

const kAliyunPushSuccessCode = "0";

///LogLevel
const kAliyunPushLogLevelError = 0;
const kAliyunPushLogLevelInfo = 1;
const kAliyunPushLogLevelDebug = 2;

///本设备
const kAliyunTargetDevice = 1;

///本设备绑定账号
const kAliyunTargetDeviceAccount = 2;

///别名
const kAliyunTargetAlias = 3;

class AliyunPush {
  @visibleForTesting
  final methodChannel = const MethodChannel('aliyun_push');

  AliyunPush._internal();

  factory AliyunPush() => _instance;

  static final AliyunPush _instance = AliyunPush._internal();

  final Platform _platform = const LocalPlatform();

  ///注册推送
  Future<Map<String, dynamic>> setup() async {
    var resultJson = await methodChannel.invokeMethod('setup');
    Map<String, dynamic> setupResult = jsonDecode(resultJson);
    return setupResult;
  }

  void closePushLog() {
    methodChannel.invokeMethod('closePushLog');
  }

  ///获取deviceId
  Future<String> getDeviceId() async {
    var deviceId = await methodChannel.invokeMethod('getDeviceId');
    return deviceId;
  }

  ///设置log的级别
  void setLogLevel(int level) {
    methodChannel.invokeMethod('setLogLevel', {'level': level});
  }

  ///绑定账号
  Future<Map<String, dynamic>> bindAccount(String account) async {
    var resultJson =
        await methodChannel.invokeMethod('bindAccount', {'account': account});
    Map<String, dynamic> bindResult = jsonDecode(resultJson);
    return bindResult;
  }

  ///解绑账号
  Future<Map<String, dynamic>> unbindAccount() async {
    var resultJson = await methodChannel.invokeMethod('unbindAccount');
    Map<String, dynamic> unbindResult = jsonDecode(resultJson);
    return unbindResult;
  }

  ///添加别名
  Future<Map<String, dynamic>> addAlias(String alias) async {
    var resultJson =
        await methodChannel.invokeMethod('addAlias', {'alias': alias});
    Map<String, dynamic> addResult = jsonDecode(resultJson);
    return addResult;
  }

  ///移除别名
  Future<Map<String, dynamic>> removeAlias(String alias) async {
    var resultJson =
        await methodChannel.invokeMethod('removeAlias', {'alias': alias});
    Map<String, dynamic> removeResult = jsonDecode(resultJson);
    return removeResult;
  }

  ///查询绑定别名
  Future<Map<String, dynamic>> listAlias() async {
    var resultJson = await methodChannel.invokeMethod('listAlias');
    Map<String, dynamic> listResult = jsonDecode(resultJson);
    return listResult;
  }

  ///添加标签
  ///
  /// @param tags     标签名
  /// @param target   目标类型，1: 本设备  2: 本设备绑定账号  3: 别名
  /// @param alias    别名（仅当target = 3时生效）
  Future<Map<String, dynamic>> bindTag(List<String> tags,
      {int target = kAliyunTargetDevice, String? alias}) async {
    var resultJson = await methodChannel.invokeMethod(
        'bindTag', {'tags': tags, 'target': target, 'alias': alias});
    Map<String, dynamic> bindResult = jsonDecode(resultJson);
    return bindResult;
  }

  ///移除标签
  ///
  /// @param tags     标签名
  /// @param target   目标类型，1: 本设备  2: 本设备绑定账号  3: 别名
  /// @param alias    别名（仅当target = 3时生效）
  Future<Map<String, dynamic>> unbindTag(List<String> tags,
      {int target = kAliyunTargetDevice, String? alias}) async {
    var resultJson = await methodChannel.invokeMethod(
        'unbindTag', {'tags': tags, 'target': target, 'alias': alias});
    Map<String, dynamic> unbindResult = jsonDecode(resultJson);
    return unbindResult;
  }

  /// 查询标签列表
  ///
  /// @param target   目标类型，1: 本设备
  Future<Map<String, dynamic>> listTags(
      {int target = kAliyunTargetDevice}) async {
    var resultJson =
        await methodChannel.invokeMethod('listTags', {'target': target});
    Map<String, dynamic> listResult = jsonDecode(resultJson);
    return listResult;
  }

  Future<Map<String, dynamic>> bindPhoneNumber(String phone) async {
    var resultJson =
        await methodChannel.invokeMethod('bindPhoneNumber', {'phone': phone});
    Map<String, dynamic> bindResult = jsonDecode(resultJson);
    return bindResult;
  }

  Future<Map<String, dynamic>> unbindPhoneNumber() async {
    var resultJson = await methodChannel.invokeMethod('unbindPhoneNumber');
    Map<String, dynamic> unbindResult = jsonDecode(resultJson);
    return unbindResult;
  }

  ///设置通知分组展示，只针对android
  ///
  ///@param inGroup 是否分组折叠展示
  void setNotificationInGroup(bool inGroup) {
    if (!_platform.isAndroid) {
      return;
    }
    methodChannel.invokeMethod('setNotificationInGroup', {'inGroup': inGroup});
  }

  void clearNotifications() {
    methodChannel.invokeMethod('clearNotifications');
  }

  ///创建Android平台的NotificationChannel
  Future<Map<String, dynamic>> createAndroidChannel(
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
    var resultJson = await methodChannel.invokeMethod('createChannel', {
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
    Map<String, dynamic> createResult = jsonDecode(resultJson);
    return createResult;
  }

  Future<Map<String, dynamic>> createAndroidChannelGroup(
      String id, String name, String desc) async {
    var resultJson = await methodChannel.invokeMethod(
        'createChannelGroup', {'id': id, 'name': name, 'desc': desc});
    Map<String, dynamic> createResult = jsonDecode(resultJson);
    return createResult;
  }

  Future<bool> isAndroidNotificationEnabled(String id) async {
    bool enabled =
        await methodChannel.invokeMethod('isNotificationEnabled', {'id': id});
    return enabled;
  }

  void jumpToAndroidNotificationSettings({String? id}) {
    methodChannel.invokeMethod('jumpToNotificationSettings');
  }
}

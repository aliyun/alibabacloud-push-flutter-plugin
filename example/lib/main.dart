import 'dart:async';
import 'dart:io';

import 'package:aliyun_push/aliyun_push.dart';
import 'package:flutter/material.dart';
import 'package:push_example/base_state.dart';
import 'package:push_example/ios.dart';

import 'android.dart';
import 'common_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BaseState<HomePage> {
  final _aliyunPush = AliyunPush();

  var _deviceId = "";

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _aliyunPush.createAndroidChannel('8.0up', '测试通道A', 3, '测试创建通知通道');
    }
    _addPushCallback();
  }

  Future<void> _onNotification(Map<dynamic, dynamic> message) async {
    showOkDialog('onNotification: $message');
  }

  Future<void> _onAndroidNotificationReceivedInApp(
      Map<dynamic, dynamic> message) async {
    showOkDialog('onAndroidNotificationReceivedInApp: $message');
  }

  Future<void> _onMessage(Map<dynamic, dynamic> message) async {
    showOkDialog('onMessage: $message');
  }

  Future<void> _onNotificationOpened(Map<dynamic, dynamic> message) async {
    showOkDialog('onNotificationOpened: $message');
  }

  Future<void> _onNotificationRemoved(Map<dynamic, dynamic> message) async {
    showOkDialog('onNotificationRemoved: $message');
  }

  Future<void> _onAndroidNotificationClickedWithNoAction(
      Map<dynamic, dynamic> message) async {
    showOkDialog('onAndroidNotificationClickedWithNoAction: $message');
  }

  Future<void> _onIOSChannelOpened(Map<dynamic, dynamic> message) async {}

  Future<void> _onIOSRegisterDeviceTokenSuccess(
      Map<dynamic, dynamic> message) async {
    showOkDialog('APNs注册成功, $message');
  }

  Future<void> _onIOSRegisterDeviceTokenFailed(
      Map<dynamic, dynamic> message) async {
    showErrorDialog('注册APNs失败, errorMsg: $message');
  }

  _addPushCallback() {
    _aliyunPush.addMessageReceiver(
        onNotification: _onNotification,
        onNotificationOpened: _onNotificationOpened,
        onNotificationRemoved: _onNotificationRemoved,
        onMessage: _onMessage,
        onAndroidNotificationReceivedInApp: _onAndroidNotificationReceivedInApp,
        onAndroidNotificationClickedWithNoAction:
            _onAndroidNotificationClickedWithNoAction,
        onIOSChannelOpened: _onIOSChannelOpened,
        onIOSRegisterDeviceTokenSuccess: _onIOSRegisterDeviceTokenSuccess,
        onIOSRegisterDeviceTokenFailed: _onIOSRegisterDeviceTokenFailed);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAliyunPush() async {
    String appKey;
    String appSecret;
    if (Platform.isIOS) {
      appKey = "填写自己iOS项目的appKey";
      appSecret = "填写自己iOS项目的appSecret";
    } else {
      appKey = "";
      appSecret = "";
    }

    _aliyunPush
        .initPush(appKey: appKey, appSecret: appSecret)
        .then((initResult) {
      var code = initResult['code'];
      if (code == kAliyunPushSuccessCode) {
        showOkDialog("初始化推送成功");
      } else {
        String errorMsg = initResult['errorMsg'];
        showErrorDialog('初始化推送失败, errorMsg: $errorMsg}');
      }
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> initAliyunThirdPush() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    _aliyunPush.initAndroidThirdPush().then((initResult) {
      var code = initResult['code'];
      if (code == kAliyunPushSuccessCode) {
        showOkDialog("初始化辅助通道成功");
      } else {
        String errorMsg = initResult['errorMsg'];
        showErrorDialog(
            '初始化辅助通道成功, errorMsg: $errorMsg');
      }
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AliyunPush Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              ElevatedButton(
                onPressed: () {
                  initAliyunPush();
                },
                child: const Text('初始化AliyunPush'),
              ),
              if (Platform.isAndroid)
                ElevatedButton(
                  onPressed: () {
                    initAliyunThirdPush();
                  },
                  child: const Text('初始化厂商通道'),
                ),
              ElevatedButton(
                  onPressed: () {
                    _aliyunPush.getDeviceId().then((deviceId) {
                      setState(() {
                        _deviceId = deviceId;
                      });
                    });
                  },
                  child: const Text('查询deviceId')),
              if (_deviceId != "")
                Text(
                  "deviceId: $_deviceId",
                  style: const TextStyle(fontSize: 16),
                ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const CommonApiPage();
                      }),
                    );
                  },
                  child: const Text('账号/别名/标签 功能')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const AndroidPage();
                      }),
                    );
                  },
                  child: const Text('Android平台特定方法')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const IOSPage();
                      }),
                    );
                  },
                  child: const Text('iOS平台特定方法')),
              ElevatedButton(
                  onPressed: () {
                    _aliyunPush.setPluginLogEnabled(true);
                  },
                  child: const Text('开启插件日志')),
              ElevatedButton(
                onPressed: () async {
                  String? level = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: const Text('选择log级别'),
                        children: <Widget>[
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, 'none'),
                            child: const Text('none'),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, 'error'),
                            child: const Text('error'),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, 'warn'),
                            child: const Text('warn'),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, 'info'),
                            child: const Text('info'),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, 'debug'),
                            child: const Text('debug'),
                          ),
                        ],
                      );
                    },
                  );
                  if (level != null) {
                    // 字符串转AliyunPushLogLevel枚举
                    AliyunPushLogLevel? logLevel;
                    switch (level) {
                      case 'none':
                        logLevel = AliyunPushLogLevel.none;
                        break;
                      case 'error':
                        logLevel = AliyunPushLogLevel.error;
                        break;
                      case 'warn':
                        logLevel = AliyunPushLogLevel.warn;
                        break;
                      case 'info':
                        logLevel = AliyunPushLogLevel.info;
                        break;
                      case 'debug':
                        logLevel = AliyunPushLogLevel.debug;
                        break;
                    }
                    if (logLevel != null) {
                      var result = await _aliyunPush.setLogLevel(logLevel);
                      var code = result['code'];
                      if (code == kAliyunPushSuccessCode) {
                        showOkDialog('设置log级别为 $level 成功');
                      } else {
                        var errorMsg = result['errorMsg'] ?? '未知错误';
                        showErrorDialog('设置log级别为 $level 失败: ' + errorMsg);
                      }
                    }
                  }
                },
                child: const Text('设置log级别'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

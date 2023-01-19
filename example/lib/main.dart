import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:push/aliyun_push.dart';
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

class _HomePageState extends State<HomePage> {
  final _aliyunPush = AliyunPush();

  var _deviceId = "";

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _aliyunPush.createAndroidChannel('8.0up', '测试通道A', 3, '测试创建通知通道');
    }
  }

  Future<void> _onNotification(Map<String, dynamic> message) async {
    Fluttertoast.showToast(
        msg: 'onNotification: $message', gravity: ToastGravity.CENTER);
  }

  Future<void> _onAndroidNotificationReceivedInApp(
      Map<String, dynamic> message) async {
    Fluttertoast.showToast(
        msg: 'onAndroidNotificationReceivedInApp: $message',
        gravity: ToastGravity.CENTER);
  }

  Future<void> _onMessage(Map<String, dynamic> message) async {
    Fluttertoast.showToast(
        msg: 'onMessage: $message', gravity: ToastGravity.CENTER);
  }

  Future<void> _onNotificationOpened(Map<String, dynamic> message) async {
    Fluttertoast.showToast(
        msg: 'onNotificationOpened: $message', gravity: ToastGravity.CENTER);
  }

  Future<void> _onNotificationRemoved(Map<String, dynamic> message) async {
    Fluttertoast.showToast(
        msg: 'onNotificationRemoved: $message', gravity: ToastGravity.CENTER);
  }

  Future<void> _onAndroidNotificationClickedWithNoAction(
      Map<String, dynamic> message) async {
    Fluttertoast.showToast(
        msg: 'onAndroidNotificationClickedWithNoAction: $message',
        gravity: ToastGravity.CENTER);
  }

  Future<void> _onIOSChannelOpened(Map<String, dynamic> message) async {
    Fluttertoast.showToast(
        msg: 'onIOSChannelOpened: $message', gravity: ToastGravity.CENTER);
  }

  Future<void> _onIOSRegisterDeviceTokenSuccess(
      Map<String, dynamic> message) async {
    Fluttertoast.showToast(
        msg: 'onIOSRegisterDeviceTokenSuccess: $message',
        gravity: ToastGravity.CENTER);
  }

  Future<void> _onIOSRegisterDeviceTokenFailed(
      Map<String, dynamic> message) async {
    Fluttertoast.showToast(
        msg: 'onIOSRegisterDeviceTokenFailed: $message',
        gravity: ToastGravity.CENTER);
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
    _addPushCallback();

    String appKey;
    String appSecret;
    if (Platform.isIOS) {
      appKey = "23793506";
      appSecret = "226c59086b35aaa711eac776e87c617c";
    } else {
      appKey = "";
      appSecret = "";
    }

    _aliyunPush.initPush(appKey: appKey, appSecret: appSecret).then((initResult) {
      var code = initResult['code'];
      if (code == kAliyunPushSuccessCode) {
        Fluttertoast.showToast(
            msg: "Init Aliyun Push successfully", gravity: ToastGravity.CENTER);
      } else {
        String errorMsg = initResult['errorMsg'];
        Fluttertoast.showToast(
            msg: 'Aliyun Push init failed, errorMsg is: $errorMsg',
            gravity: ToastGravity.CENTER);
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
        Fluttertoast.showToast(
            msg: "Init Aliyun Third Push successfully",
            gravity: ToastGravity.CENTER);
      } else {
        String errorMsg = initResult['errorMsg'];
        Fluttertoast.showToast(
            msg: 'Aliyun Third Push init failed, errorMsg is: $errorMsg',
            gravity: ToastGravity.CENTER);
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
                  child: const Text('iOS平台特定方法'))
            ],
          ),
        ),
      ),
    );
  }
}

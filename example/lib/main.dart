import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:push/aliyun_push.dart';

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
  final _pushPlugin = AliyunPush();

  var _deviceId = "";

  final List<String> _logLevelList = ['ERROR', 'INFO', 'DEBUG'];

  String? _selectedLogLevel;

  @override
  void initState() {
    super.initState();
    _selectedLogLevel = "DEBUG";
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAliyunPush() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    _pushPlugin.setup().then((setupResult) {
      var code = setupResult['code'];
      if (code == kAliyunPushSuccessCode) {
        Fluttertoast.showToast(
            msg: "Aliyun Push setup successfully",
            gravity: ToastGravity.CENTER);
      } else {
        String errorMsg = setupResult['errorMsg'];
        Fluttertoast.showToast(
            msg: 'Aliyun Push setup failed, errorMsg is: $errorMsg',
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
              ElevatedButton(
                onPressed: () {
                  _pushPlugin.closePushLog();
                },
                child: const Text('关闭AliyunPush Log'),
              ),
              ElevatedButton(
                  onPressed: () {
                    _pushPlugin.getDeviceId().then((deviceId) {
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    hint: Text(
                      'Select Item',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: _logLevelList
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
                    value: _selectedLogLevel,
                    onChanged: (value) {
                      setState(() {
                        _selectedLogLevel = value as String;
                      });
                    },
                    buttonHeight: 40,
                    buttonWidth: 140,
                    itemHeight: 40,
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    int logLevel;
                    if (_selectedLogLevel == 'ERROR') {
                      logLevel = kAliyunPushLogLevelError;
                    } else if (_selectedLogLevel == 'INFO') {
                      logLevel = kAliyunPushLogLevelInfo;
                    } else {
                      logLevel = kAliyunPushLogLevelDebug;
                    }
                    _pushPlugin.setLogLevel(logLevel);
                  },
                  child: Text('设置LogLevel为 $_selectedLogLevel')),
              ElevatedButton(onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const CommonApiPage();
                  }),
                );
              }, child: const Text('账号/别名/标签 功能')),
              ElevatedButton(onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const AndroidPage();
                  }),
                );
              }, child: const Text('Android平台特定方法'))
            ],
          ),
        ),
      ),
    );
  }
}

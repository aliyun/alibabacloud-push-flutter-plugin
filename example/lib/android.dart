import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:aliyun_push/aliyun_push.dart';

class AndroidPage extends StatefulWidget {
  const AndroidPage({super.key});

  @override
  State<StatefulWidget> createState() => _AndroidPageState();
}

class _AndroidPageState extends State<AndroidPage> {
  final _aliyunPush = AliyunPush();

  final TextEditingController _addPhoneController = TextEditingController();
  final TextEditingController _channelController = TextEditingController();

  String _boundPhone = "";

  final List<String> _logLevelList = ['ERROR', 'INFO', 'DEBUG'];

  String? _selectedLogLevel;

  @override
  void initState() {
    super.initState();
    _selectedLogLevel = "DEBUG";
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    children.add(
      ElevatedButton(
        onPressed: () {
          _aliyunPush.closeAndroidPushLog().then((result) {
            var code = result['code'];
            if (code == kAliyunPushSuccessCode) {
              Fluttertoast.showToast(
                  msg: '关闭AliyunPush Log成功', gravity: ToastGravity.CENTER);
            }
          });
        },
        child: const Text('关闭AliyunPush Log'),
      ),
    );
    _addSetLogLevelView(children);
    children.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: const Text(
          '手机号码绑定/解绑',
          style: TextStyle(color: Colors.white),
        ),
        tileColor: Colors.grey.shade400,
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    ));
    _addBindPhoneView(children);
    _addUnbindPhoneView(children);
    children.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: const Text(
          '通知设置',
          style: TextStyle(color: Colors.white),
        ),
        tileColor: Colors.grey.shade400,
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.setNotificationInGroup(true).then((result){
              var code = result['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '开启通知分组展示成功', gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('开启通知分组展示')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.setNotificationInGroup(false).then((result) {
              var code = result['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '关闭通知分组展示成功', gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('关闭通知分组展示')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.clearNotifications().then((result) {
              var code = result['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '清除所有通知', gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('清除所有通知')),
    ));
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          autofocus: false,
          decoration: const InputDecoration(
            labelText: "通道名称",
            hintText: "通道名称",
          ),
          controller: _channelController,
        ),
      ),
    );
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            if (_channelController.text == '') {
              Fluttertoast.showToast(
                  msg: '通道名称不能为空', gravity: ToastGravity.CENTER);
              return;
            }
            var channel = _channelController.text;
            _aliyunPush
                .createAndroidChannel(
                    _channelController.text, '测试通道A', 3, '测试创建通知通道')
                .then((createResult) {
              var code = createResult['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '创建$channel通道成功', gravity: ToastGravity.CENTER);
              } else {
                var errorCode = createResult['code'];
                var errorMsg = createResult['errorMsg'];
                Fluttertoast.showToast(
                    msg: '创建$channel通道失败, $errorCode - $errorMsg',
                    gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('创建NotificationChannel')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () async {
            bool isEnabled = await _aliyunPush.isAndroidNotificationEnabled();
            Fluttertoast.showToast(
                msg: '通知状态: $isEnabled', gravity: ToastGravity.CENTER);
          },
          child: const Text('检查通知状态')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () async {
            bool isEnabled = await _aliyunPush.isAndroidNotificationEnabled(
                id: _channelController.text);
            Fluttertoast.showToast(
                msg: '通知状态: $isEnabled', gravity: ToastGravity.CENTER);
          },
          child: const Text('检查通知通道状态')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.jumpToAndroidNotificationSettings();
          },
          child: const Text('跳转通知设置界面')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.jumpToAndroidNotificationSettings(
                id: _channelController.text);
          },
          child: const Text('跳转通知通道设置界面')),
    ));

    return Scaffold(
        appBar: AppBar(
          title: const Text('Android平台方法'),
        ),
        body: ListView(
          shrinkWrap: true,
          children: children,
        ));
  }

  _addSetLogLevelView(List<Widget> children) {
    children.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          hint: Text(
            'Select LogLevel',
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
    ));
    children.add(ElevatedButton(
        onPressed: () {
          int logLevel;
          if (_selectedLogLevel == 'ERROR') {
            logLevel = kAliyunPushLogLevelError;
          } else if (_selectedLogLevel == 'INFO') {
            logLevel = kAliyunPushLogLevelInfo;
          } else {
            logLevel = kAliyunPushLogLevelDebug;
          }
          _aliyunPush.setAndroidLogLevel(logLevel).then((result) {
            var code = result['code'];
            if (code == kAliyunPushSuccessCode) {
              Fluttertoast.showToast(
                  msg: '成功设置LogLevel为 $_selectedLogLevel', gravity: ToastGravity.CENTER);
            } else {
              var errorCode = result['code'];
              var errorMsg = result['errorMsg'];
              Fluttertoast.showToast(
                  msg: '设置LogLevel失败, $errorCode - $errorMsg',
                  gravity: ToastGravity.CENTER);
            }
          });
        },
        child: Text('设置LogLevel为 $_selectedLogLevel')));
  }

  _addBindPhoneView(List<Widget> children) {
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          autofocus: false,
          decoration: const InputDecoration(
            labelText: "绑定的手机号码",
            hintText: "绑定的手机号码",
          ),
          controller: _addPhoneController,
        ),
      ),
    );
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            var phone = _addPhoneController.text;
            if (phone != '') {
              _aliyunPush.bindPhoneNumber(phone).then((bindResult) {
                var code = bindResult['code'];
                if (code == kAliyunPushSuccessCode) {
                  Fluttertoast.showToast(
                      msg: '绑定手机吗$phone成功', gravity: ToastGravity.CENTER);
                  setState(() {
                    _boundPhone = phone;
                  });
                  _addPhoneController.clear();
                } else {
                  var errorCode = bindResult['code'];
                  var errorMsg = bindResult['errorMsg'];
                  Fluttertoast.showToast(
                      msg: '绑定手机号码$phone失败, $errorCode - $errorMsg',
                      gravity: ToastGravity.CENTER);
                }
              });
            } else {
              Fluttertoast.showToast(
                  msg: '请输入要绑定的手机号码', gravity: ToastGravity.CENTER);
            }
          },
          child: const Text('绑定手机号码')),
    ));
    if (_boundPhone != '') {
      children.add(Text('已绑定手机号码: $_boundPhone'));
    }
  }

  _addUnbindPhoneView(List<Widget> children) {
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.unbindPhoneNumber().then((unbindResult) {
              var code = unbindResult['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '解绑手机号码成功', gravity: ToastGravity.CENTER);
                setState(() {
                  _boundPhone = "";
                });
              } else {
                var errorCode = unbindResult['code'];
                var errorMsg = unbindResult['errorMsg'];
                Fluttertoast.showToast(
                    msg: '解绑手机号码成功, $errorCode - $errorMsg',
                    gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('解绑手机号码')),
    ));
  }
}

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:aliyun_push/aliyun_push.dart';
import 'package:push_example/base_state.dart';

class AndroidPage extends StatefulWidget {
  const AndroidPage({super.key});

  @override
  State<StatefulWidget> createState() => _AndroidPageState();
}

class _AndroidPageState extends BaseState<AndroidPage> {
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
              showOkDialog('关闭AliyunPush Log成功');
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
            _aliyunPush.setNotificationInGroup(true).then((result) {
              var code = result['code'];
              if (code == kAliyunPushSuccessCode) {
                showOkDialog('开启通知分组展示成功');
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
                showOkDialog('关闭通知分组展示成功');
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
                showOkDialog('清除所有通知');
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
              showWarningDialog('通道名称不能为空');
              return;
            }
            var channel = _channelController.text;
            _aliyunPush
                .createAndroidChannel(
                    _channelController.text, '测试通道A', 3, '测试创建通知通道')
                .then((createResult) {
              var code = createResult['code'];
              if (code == kAliyunPushSuccessCode) {

                showOkDialog('创建$channel通道成功');
              } else {
                var errorCode = createResult['code'];
                var errorMsg = createResult['errorMsg'];
                showErrorDialog('创建$channel通道失败, $errorCode - $errorMsg');
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
            showOkDialog('通知状态: $isEnabled');
          },
          child: const Text('检查通知状态')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () async {
            bool isEnabled = await _aliyunPush.isAndroidNotificationEnabled(
                id: _channelController.text);
            showOkDialog('通知状态: $isEnabled');
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
              showOkDialog('成功设置LogLevel为 $_selectedLogLevel');
            } else {
              var errorCode = result['code'];
              var errorMsg = result['errorMsg'];
              showErrorDialog('设置LogLevel失败, $errorCode - $errorMsg');
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
                  setState(() {
                    _boundPhone = phone;
                  });
                  _addPhoneController.clear();
                  showOkDialog('绑定手机$phone成功');
                } else {
                  var errorCode = bindResult['code'];
                  var errorMsg = bindResult['errorMsg'];
                  showErrorDialog('绑定手机号码$phone失败, $errorCode - $errorMsg');
                }
              });
            } else {
              showOkDialog('请输入要绑定的手机号码');
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
                showOkDialog('解绑手机号码成功');
                setState(() {
                  _boundPhone = "";
                });
              } else {
                var errorCode = unbindResult['code'];
                var errorMsg = unbindResult['errorMsg'];
                showErrorDialog('解绑手机号码失败, $errorCode - $errorMsg');
              }
            });
          },
          child: const Text('解绑手机号码')),
    ));
  }
}

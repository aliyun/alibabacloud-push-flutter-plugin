
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:push/aliyun_push.dart';

class AndroidPage extends StatefulWidget {
  const AndroidPage({super.key});

  @override
  State<StatefulWidget> createState() => _AndroidPageState();

}

class _AndroidPageState extends State<AndroidPage> {

  final _pushPlugin = AliyunPush();

  final TextEditingController _addPhoneController = TextEditingController();
  final TextEditingController _channelController = TextEditingController();

  String _boundPhone = "";

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    children.add( Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: const Text('手机号码绑定/解绑', style: TextStyle(color: Colors.white),),
        tileColor: Colors.grey.shade400,
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    ));
    _addBindPhoneView(children);
    _addUnbindPhoneView(children);
    children.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: const Text('通知设置', style: TextStyle(color: Colors.white),),
        tileColor: Colors.grey.shade400,
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _pushPlugin.setNotificationInGroup(true);
          },
          child: const Text('开启通知分组展示')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _pushPlugin.setNotificationInGroup(false);
          },
          child: const Text('关闭通知分组展示')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _pushPlugin.clearNotifications();
          },
          child: const Text('清除所有通知')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        autofocus: false,
        decoration: const InputDecoration(
          labelText: "通道名称",
          hintText: "通道名称",
        ),
        controller: _channelController,
      ),
    ),);
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            if (_channelController.text == '') {
              Fluttertoast.showToast(msg: '通道名称不能为空', gravity: ToastGravity.CENTER);
              return;
            }
            var channel = _channelController.text;
            _pushPlugin.createAndroidChannel(_channelController.text, '测试通道A', 3, '测试创建通知通道').then((createResult){
              var code = createResult['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '创建$channel通道成功',
                    gravity: ToastGravity.CENTER);
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
            bool isEnabled = await _pushPlugin.isAndroidNotificationEnabled();
            Fluttertoast.showToast(msg: '通知状态: $isEnabled', gravity: ToastGravity.CENTER);
          },
          child: const Text('检查通知状态')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () async {
            bool isEnabled = await _pushPlugin.isAndroidNotificationEnabled(id: _channelController.text);
            Fluttertoast.showToast(msg: '通知状态: $isEnabled', gravity: ToastGravity.CENTER);
          },
          child: const Text('检查通知通道状态')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _pushPlugin.jumpToAndroidNotificationSettings();
          },
          child: const Text('跳转通知设置界面')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _pushPlugin.jumpToAndroidNotificationSettings(id: _channelController.text);
          },
          child: const Text('跳转通知通道设置界面')),
    ));


    return Scaffold(
        appBar: AppBar(
          title: const Text('Android平台方法'),
        ),
        body:ListView(
          shrinkWrap: true,
          children: children,
        )

    );
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
              _pushPlugin.bindPhoneNumber(phone).then((bindResult) {
                var code = bindResult['code'];
                if (code == kAliyunPushSuccessCode) {
                  Fluttertoast.showToast(
                      msg: '绑定手机吗$phone成功',
                      gravity: ToastGravity.CENTER);
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
            _pushPlugin.unbindPhoneNumber().then((unbindResult) {
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
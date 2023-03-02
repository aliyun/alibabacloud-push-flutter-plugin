import 'package:aliyun_push/aliyun_push.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class IOSPage extends StatefulWidget {
  const IOSPage({super.key});

  @override
  State<StatefulWidget> createState() => _IOSPageState();
}

class _IOSPageState extends State<IOSPage> {
  final _aliyunPush = AliyunPush();

  final TextEditingController _badgeController = TextEditingController();

  String _apnsToken = "";

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.turnOnIOSDebug().then((result) {
              var code = result['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '打开debug日志成功', gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('打开debug日志')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.showIOSNoticeWhenForeground(true).then((result) {
              var code = result['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '设置前台显示通知成功', gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('前台显示通知')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.showIOSNoticeWhenForeground(false).then((result) {
              var code = result['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '设置前台不显示通知成功', gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('前台不显示通知')),
    ));
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          autofocus: false,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "角标个数",
            hintText: "角标个数",
          ),
          controller: _badgeController,
        ),
      ),
    );
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            if (_badgeController.text == '') {
              Fluttertoast.showToast(
                  msg: '角标个数不能为空', gravity: ToastGravity.CENTER);
              return;
            }
            int badgeNum = int.parse(_badgeController.text);
            _aliyunPush.setIOSBadgeNum(badgeNum).then((result) {
              var code = result['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '设置角标个数$badgeNum成功', gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('设置角标个数')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            if (_badgeController.text == '') {
              Fluttertoast.showToast(
                  msg: '角标个数不能为空', gravity: ToastGravity.CENTER);
              return;
            }
            int badgeNum = int.parse(_badgeController.text);
            _aliyunPush.syncIOSBadgeNum(badgeNum).then((result) {
              var code = result['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '同步角标个数$badgeNum成功', gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('同步角标个数')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.getApnsDeviceToken().then((apnsToken) {
              setState(() {
                _apnsToken = apnsToken;
              });
            });
          },
          child: const Text('查询ApnsToken')),
    ));
    children.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
            _aliyunPush.isIOSChannelOpened().then((opened) {
              if (opened) {
                Fluttertoast.showToast(
                    msg: '通道已打开', gravity: ToastGravity.CENTER);
              } else {
                Fluttertoast.showToast(
                    msg: '通道未打开', gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('通知通道是否打开')),
    ));
    if (_apnsToken != "") {
      children.add(Text(
        "apnsToken: $_apnsToken",
        style: const TextStyle(fontSize: 16),
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('iOS平台方法'),
        ),
        body: ListView(
          shrinkWrap: true,
          children: children,
        ));
  }
}

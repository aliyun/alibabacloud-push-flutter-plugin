import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:aliyun_push/aliyun_push.dart';

class CommonApiPage extends StatefulWidget {
  const CommonApiPage({super.key});

  @override
  State<StatefulWidget> createState() => _CommonApiPageState();
}

class _CommonApiPageState extends State<CommonApiPage> {
  final _pushPlugin = AliyunPush();

  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _addAliasController = TextEditingController();
  final TextEditingController _removeAliasController = TextEditingController();
  final TextEditingController _addTagController = TextEditingController();
  final TextEditingController _addAccountTagController =
      TextEditingController();
  final TextEditingController _removeTagController = TextEditingController();
  final TextEditingController _removeAccountTagController =
      TextEditingController();

  String _boundAccount = "";

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    children.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: const Text(
          '账号绑定/解绑',
          style: TextStyle(color: Colors.white),
        ),
        tileColor: Colors.grey.shade400,
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    ));
    _addBindAccountView(children);
    _addUnbindAccountView(children);
    children.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: const Text(
          '别名添加/删除',
          style: TextStyle(color: Colors.white),
        ),
        tileColor: Colors.grey.shade400,
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    ));
    _addBindAliasView(children);
    _addUnbindAliasView(children);
    _addListAliasView(children);
    children.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: const Text(
          '设备标签添加/删除/查询',
          style: TextStyle(color: Colors.white),
        ),
        tileColor: Colors.grey.shade400,
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    ));
    _addBindDeviceTagView(children);
    _addUnbindDeviceTagView(children);
    children.add(ElevatedButton(
        onPressed: () {
          _pushPlugin
              .listTags(target: kAliyunTargetDevice)
              .then((listTagsResult) {
            var code = listTagsResult['code'];
            if (code == kAliyunPushSuccessCode) {
              var tagsList = listTagsResult['tagsList'];
              Fluttertoast.showToast(
                  msg: '查询标签列表结果为 $tagsList', gravity: ToastGravity.CENTER);
            } else {
              var errorCode = listTagsResult['code'];
              var errorMsg = listTagsResult['errorMsg'];
              Fluttertoast.showToast(
                  msg: '查询标签列表失败, $errorCode - $errorMsg',
                  gravity: ToastGravity.CENTER);
            }
          });
        },
        child: const Text('查询设备标签列表')));
    children.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: const Text(
          '账号标签添加/删除',
          style: TextStyle(color: Colors.white),
        ),
        tileColor: Colors.grey.shade400,
        trailing: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
        ),
      ),
    ));
    _addBindAccountTagView(children);
    _addUnbindAccountTagView(children);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Account/Alias/Tag'),
        ),
        body: ListView(
          shrinkWrap: true,
          children: children,
        ));
  }

  _addBindAccountView(List<Widget> children) {
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          autofocus: false,
          decoration: const InputDecoration(
            labelText: "绑定的账号",
            hintText: "绑定的账号",
          ),
          controller: _accountController,
        ),
      ),
    );
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            var account = _accountController.text;
            if (account != '') {
              _pushPlugin.bindAccount(account).then((bindResult) {
                var code = bindResult['code'];
                if (code == kAliyunPushSuccessCode) {
                  Fluttertoast.showToast(
                      msg: '绑定账号$account成功', gravity: ToastGravity.CENTER);
                  setState(() {
                    _boundAccount = account;
                  });
                  _accountController.clear();
                } else {
                  var errorCode = bindResult['code'];
                  var errorMsg = bindResult['errorMsg'];
                  Fluttertoast.showToast(
                      msg: '绑定账号$account失败, $errorCode - $errorMsg',
                      gravity: ToastGravity.CENTER);
                }
              });
            } else {
              Fluttertoast.showToast(
                  msg: '请输入要绑定的账号', gravity: ToastGravity.CENTER);
            }
          },
          child: const Text('绑定账号')),
    ));
    if (_boundAccount != '') {
      children.add(Text('已绑定账号: $_boundAccount'));
    }
  }

  _addUnbindAccountView(List<Widget> children) {
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _pushPlugin.unbindAccount().then((unbindResult) {
              var code = unbindResult['code'];
              if (code == kAliyunPushSuccessCode) {
                Fluttertoast.showToast(
                    msg: '解绑账号成功', gravity: ToastGravity.CENTER);
                setState(() {
                  _boundAccount = "";
                });
                _accountController.clear();
              } else {
                var errorCode = unbindResult['code'];
                var errorMsg = unbindResult['errorMsg'];
                Fluttertoast.showToast(
                    msg: '解绑账号失败, $errorCode - $errorMsg',
                    gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('解绑账号')),
    ));
  }

  _addBindAliasView(List<Widget> children) {
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        autofocus: false,
        decoration: const InputDecoration(
          labelText: "添加的别名",
          hintText: "添加的别名",
        ),
        controller: _addAliasController,
      ),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            var alias = _addAliasController.text;
            if (alias != '') {
              _pushPlugin.addAlias(alias).then((addResult) {
                var code = addResult['code'];
                if (code == kAliyunPushSuccessCode) {
                  Fluttertoast.showToast(
                      msg: '添加别名$alias成功', gravity: ToastGravity.CENTER);
                  _addAliasController.clear();
                } else {
                  var errorCode = addResult['code'];
                  var errorMsg = addResult['errorMsg'];
                  Fluttertoast.showToast(
                      msg: '添加别名$alias失败, $errorCode - $errorMsg',
                      gravity: ToastGravity.CENTER);
                }
              });
            } else {
              Fluttertoast.showToast(
                  msg: '请输入要添加的别名', gravity: ToastGravity.CENTER);
            }
          },
          child: const Text('添加别名')),
    ));
  }

  _addUnbindAliasView(List<Widget> children) {
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          autofocus: false,
          decoration: const InputDecoration(
            labelText: "删除的别名",
            hintText: "删除的别名",
          ),
          controller: _removeAliasController,
        ),
      ),
    );
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            var alias = _removeAliasController.text;
            if (alias != '') {
              _pushPlugin.removeAlias(alias).then((removeResult) {
                var code = removeResult['code'];
                if (code == kAliyunPushSuccessCode) {
                  Fluttertoast.showToast(
                      msg: '删除别名$alias成功', gravity: ToastGravity.CENTER);
                  _removeAliasController.clear();
                } else {
                  var errorCode = removeResult['code'];
                  var errorMsg = removeResult['errorMsg'];
                  Fluttertoast.showToast(
                      msg: '删除别名$alias失败, $errorCode - $errorMsg',
                      gravity: ToastGravity.CENTER);
                }
              });
            } else {
              Fluttertoast.showToast(
                  msg: '请输入要删除的别名', gravity: ToastGravity.CENTER);
            }
          },
          child: const Text('删除别名')),
    ));
  }

  _addListAliasView(List<Widget> children) {
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            _pushPlugin.listAlias().then((listAliasResult) {
              var code = listAliasResult['code'];
              if (code == kAliyunPushSuccessCode) {
                var aliasList = listAliasResult['aliasList'];
                Fluttertoast.showToast(
                    msg: '查询别名列表结果为 $aliasList', gravity: ToastGravity.CENTER);
              } else {
                var errorCode = listAliasResult['code'];
                var errorMsg = listAliasResult['errorMsg'];
                Fluttertoast.showToast(
                    msg: '查询别名列表失败, $errorCode - $errorMsg',
                    gravity: ToastGravity.CENTER);
              }
            });
          },
          child: const Text('查询别名列表')),
    ));
  }

  _addBindDeviceTagView(List<Widget> children) {
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        autofocus: false,
        decoration: const InputDecoration(
          labelText: "给设备添加的标签",
          hintText: "给设备添加的标签",
        ),
        controller: _addTagController,
      ),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            var tag = _addTagController.text;
            if (tag != '') {
              var tags = <String>[];
              tags.add(tag);
              _pushPlugin.bindTag(tags).then((bindTagResult) {
                print('$bindTagResult');
                var code = bindTagResult['code'];
                if (code == kAliyunPushSuccessCode) {
                  Fluttertoast.showToast(
                      msg: '添加标签$tag成功', gravity: ToastGravity.CENTER);
                  _addTagController.clear();
                } else {
                  var errorCode = bindTagResult['code'];
                  var errorMsg = bindTagResult['errorMsg'];
                  Fluttertoast.showToast(
                      msg: '添加标签$tag失败, $errorCode - $errorMsg',
                      gravity: ToastGravity.CENTER);
                }
              });
            } else {
              Fluttertoast.showToast(
                  msg: '请输入要添加的标签', gravity: ToastGravity.CENTER);
            }
          },
          child: const Text('给设备添加标签')),
    ));
  }

  _addUnbindDeviceTagView(List<Widget> children) {
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          autofocus: false,
          decoration: const InputDecoration(
            labelText: "删除的设备标签",
            hintText: "删除的设备标签",
          ),
          controller: _removeTagController,
        ),
      ),
    );
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            var tag = _removeTagController.text;
            if (tag != '') {
              var tags = <String>[];
              tags.add(tag);
              _pushPlugin.unbindTag(tags).then((bindTagResult) {
                var code = bindTagResult['code'];
                if (code == kAliyunPushSuccessCode) {
                  Fluttertoast.showToast(
                      msg: '删除标签$tag成功', gravity: ToastGravity.CENTER);
                  _removeTagController.clear();
                } else {
                  var errorCode = bindTagResult['code'];
                  var errorMsg = bindTagResult['errorMsg'];
                  Fluttertoast.showToast(
                      msg: '删除标签$tag失败, $errorCode - $errorMsg',
                      gravity: ToastGravity.CENTER);
                }
              });
            } else {
              Fluttertoast.showToast(
                  msg: '请输入要删除的标签', gravity: ToastGravity.CENTER);
            }
          },
          child: const Text('删除设备标签')),
    ));
  }

  _addBindAccountTagView(List<Widget> children) {
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          autofocus: false,
          decoration: const InputDecoration(
            labelText: "给账号添加的标签",
            hintText: "给账号添加的标签",
          ),
          controller: _addAccountTagController,
        ),
      ),
    );
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            var tag = _addAccountTagController.text;
            if (tag != '') {
              var tags = <String>[];
              tags.add(tag);
              _pushPlugin
                  .bindTag(tags, target: kAliyunTargetAccount)
                  .then((bindTagResult) {
                var code = bindTagResult['code'];
                if (code == kAliyunPushSuccessCode) {
                  Fluttertoast.showToast(
                      msg: '添加标签$tag成功', gravity: ToastGravity.CENTER);
                  _addAccountTagController.clear();
                } else {
                  var errorCode = bindTagResult['code'];
                  var errorMsg = bindTagResult['errorMsg'];
                  Fluttertoast.showToast(
                      msg: '添加标签$tag失败, $errorCode - $errorMsg',
                      gravity: ToastGravity.CENTER);
                }
              });
            } else {
              Fluttertoast.showToast(
                  msg: '请输入要添加的标签', gravity: ToastGravity.CENTER);
            }
          },
          child: const Text('给账号添加标签')),
    ));
  }

  _addUnbindAccountTagView(List<Widget> children) {
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        autofocus: false,
        decoration: const InputDecoration(
          labelText: "删除的账号标签",
          hintText: "删除的账号标签",
        ),
        controller: _removeAccountTagController,
      ),
    ));
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
          onPressed: () {
            var tag = _removeAccountTagController.text;
            if (tag != '') {
              var tags = <String>[];
              tags.add(tag);
              _pushPlugin
                  .unbindTag(tags, target: kAliyunTargetAccount)
                  .then((bindTagResult) {
                var code = bindTagResult['code'];
                if (code == kAliyunPushSuccessCode) {
                  Fluttertoast.showToast(
                      msg: '删除标签$tag成功', gravity: ToastGravity.CENTER);
                  _removeAccountTagController.clear();
                } else {
                  var errorCode = bindTagResult['code'];
                  var errorMsg = bindTagResult['errorMsg'];
                  Fluttertoast.showToast(
                      msg: '删除标签$tag失败, $errorCode - $errorMsg',
                      gravity: ToastGravity.CENTER);
                }
              });
            } else {
              Fluttertoast.showToast(
                  msg: '请输入要删除的标签', gravity: ToastGravity.CENTER);
            }
          },
          child: const Text('删除账号标签')),
    ));
  }
}

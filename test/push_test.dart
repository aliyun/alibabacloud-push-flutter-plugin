import 'package:flutter_test/flutter_test.dart';
import 'package:push/aliyun_push.dart';
import 'package:push/push_platform_interface.dart';
import 'package:push/push_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPushPlatform with MockPlatformInterfaceMixin implements PushPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PushPlatform initialPlatform = PushPlatform.instance;

  test('$MethodChannelPush is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPush>());
  });

  test('getPlatformVersion', () async {
    AliyunPush pushPlugin = AliyunPush();
    MockPushPlatform fakePlatform = MockPushPlatform();
    PushPlatform.instance = fakePlatform;

    expect(await pushPlugin.getPlatformVersion(), '42');
  });
}

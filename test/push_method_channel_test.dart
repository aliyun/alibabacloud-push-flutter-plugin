import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push/push_method_channel.dart';

void main() {
  MethodChannelPush platform = MethodChannelPush();
  const MethodChannel channel = MethodChannel('push');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flt_pay_wechat/flt_pay_wechat.dart';

void main() {
  const MethodChannel channel = MethodChannel('flt_pay_wechat');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
//    expect(await FltPayWechat.platformVersion, '42');
  });
}

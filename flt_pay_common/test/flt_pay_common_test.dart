import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flt_pay_common/flt_pay_common.dart';

void main() {
  const MethodChannel channel = MethodChannel('flt_pay_common');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FltPayCommon.platformVersion, '42');
  });
}

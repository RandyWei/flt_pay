import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flt_pay_ali/flt_pay_ali.dart';

void main() {
  const MethodChannel channel = MethodChannel('flt_pay_ali');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FltPayAli.platformVersion, '42');
  });
}

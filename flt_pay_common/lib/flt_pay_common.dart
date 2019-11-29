import 'dart:async';

import 'package:flutter/services.dart';

class FltPayCommon {
  static const MethodChannel _channel =
      const MethodChannel('flt_pay_common');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

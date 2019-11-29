import 'dart:async';

import 'package:flutter/services.dart';

class FltPayAli {
  static const MethodChannel _channel =
      const MethodChannel('flt_pay_ali');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

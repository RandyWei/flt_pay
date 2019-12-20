import 'dart:async';

import 'package:flutter/services.dart';

class FltPayAli {
  static const MethodChannel _channel = const MethodChannel('flt_pay_ali');

  static Future<String> aliPay(String payInfo) async {
    final String result =
        await _channel.invokeMethod('aliPay', {"payInfo": payInfo});
    return result;
  }
}

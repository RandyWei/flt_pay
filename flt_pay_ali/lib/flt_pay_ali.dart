import 'dart:async';

import 'package:flutter/services.dart';

class FltPayAli {
  static Function(String? result)? _callback;
  static final MethodChannel _channel = MethodChannel('flt_pay_ali')
    ..setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case "aliPayResult":
          if (call.arguments is String) {
            _callback?.call(call.arguments);
          }
          return Future.value(null);
        default:
          return Future.value(null);
      }
    });

  static Future aliInit(String scheme) async {
    await _channel.invokeMethod('aliInit', {"scheme": scheme});
  }

  static Future aliPay(
      String payInfo, Function(String? result) callback) async {
    _callback = callback;
    await _channel.invokeMethod('aliPay', {"payInfo": payInfo});
  }
}

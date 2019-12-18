import 'dart:async';

import 'package:flutter/services.dart';

class FltPayWechat {
  static Function(String result) _callback;
  static final MethodChannel _channel = MethodChannel('flt_pay_wechat')
    ..setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case "weChatPayResult":
          if (call.arguments is String) {
            _callback?.call(call.arguments);
          }
          return null;
        default:
          return null;
      }
    });

  static Future weChatInit(String appId) async {
    await _channel.invokeMethod('weChatInit', {"appId": appId});
  }

  static Future weChatPay(
      Map<String, String> payInfo, Function(String result) callback) async {
    _callback = callback;
    await _channel.invokeMethod('weChatPay', {
      "appId": payInfo["appId"],
      "partnerId": payInfo["partnerId"],
      "prepayId": payInfo["prepayId"],
      "nonceStr": payInfo["nonceStr"],
      "timeStamp": payInfo["timeStamp"],
      "packageValue": payInfo["packageValue"],
      "sign": payInfo["sign"],
      "extData": payInfo["extData"],
    });
  }
}

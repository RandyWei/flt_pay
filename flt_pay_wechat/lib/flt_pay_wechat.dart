import 'dart:async';

import 'package:flutter/services.dart';

class FltPayWechat {
  static Function(String? result)? _callback;
  static final MethodChannel _channel = MethodChannel('flt_pay_wechat')
    ..setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case "weChatPayResult":
          if (call.arguments is String) {
            _callback?.call(call.arguments);
          }
          return Future.value(null);
        default:
          return Future.value(null);
      }
    } );

  static Future weChatInit(String appId, String scheme) async {
    await _channel
        .invokeMethod('weChatInit', {"appId": appId, "scheme": scheme});
  }

  static Future weChatPay(
      Map<String, dynamic> payInfo, Function(String? result) callback) async {
    _callback = callback;
    var arguments = {
      "appId": payInfo["appid"],
      "partnerId": payInfo["partnerid"],
      "prepayId": payInfo["prepayid"],
      "nonceStr": payInfo["noncestr"],
      "timeStamp": payInfo["timestamp"],
      "packageValue": payInfo["package"],
      "sign": payInfo["sign"],
      "extData": payInfo["extData"],
    };
    print('FltPayWechat.weChatPay payInfo=$payInfo');
    print('FltPayWechat.weChatPay arguments=$arguments');
    await _channel.invokeMethod('weChatPay', arguments);
  }
}

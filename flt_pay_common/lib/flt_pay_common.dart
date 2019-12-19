library flt_pay_common;

import 'package:flutter/foundation.dart';

/// 支付方式
enum PaymentType {
  /// 微信支付
  WeChatPay,

  /// 支付宝
  AliPay,

  /// 未定义的支付方式
  Undefined,
}

/// 支付结果
enum PayResult {
  /// 支付成功
  Success,

  /// 支付失败
  Fail,

  /// 用户取消
  Cancel,
}

/// 通用支付方式定义
abstract class CommonPay {
  /// 支付方式初始化
  CommonPay paymentInit(data);

  /// 支付
  Future<PayResult> pay(payInfo);

  /// 支付方式的类型，使用[PaymentType]定义
  PaymentType paymentType();
}

/// 注册的支付方式
List<CommonPay> _commonPayList = [];

/// 用于容错的背锅侠
class _EmptyPay extends CommonPay {
  @override
  Future<PayResult> pay(payInfo) async => PayResult.Fail;

  @override
  CommonPay paymentInit(data) => this;

  @override
  PaymentType paymentType() => PaymentType.Undefined;
}

/// 注册支付方式，只有注册过才可以在[pay]方法中使用
void registerPayment(List<CommonPay> commonPay) {
  if (commonPay == null || commonPay.isEmpty) {
    return;
  }

  _commonPayList.clear();
  _commonPayList.addAll(commonPay);
}

/// 发起支付方法
Future<PayResult> pay({
  @required PaymentType type,
  @required payInfo,
  initData,
}) async {
  var payment = _commonPayList.firstWhere((pay) => pay.paymentType() == type,
      orElse: () => _EmptyPay());
  if (initData != null) {
    payment.paymentInit(initData);
  }
  return await payment.pay(payInfo);
}

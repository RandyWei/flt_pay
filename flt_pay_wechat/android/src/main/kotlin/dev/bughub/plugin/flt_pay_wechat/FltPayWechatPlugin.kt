package dev.bughub.plugin.flt_pay_wechat

import android.content.Context
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelpay.PayReq
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FltPayWechatPlugin(private val context: Context) : MethodCallHandler, EventChannel.StreamHandler {
    companion object {
        var channel: MethodChannel? = null
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            channel = MethodChannel(registrar.messenger(), "flt_pay_wechat")
            channel?.setMethodCallHandler(FltPayWechatPlugin(registrar.context()))
        }

        fun handlePayResponse(resp: BaseResp) {
            when (resp.errCode) {
                0 -> {
                    // 成功
                    channel?.invokeMethod("weChatPayResult", "Success")
                }
                -1 -> {
                    // -1错误 可能的原因：签名错误、未注册APP_ID、项目设置APP_ID不正确、注册的APP_ID与设置的不匹配、其他异常等。
                    channel?.invokeMethod("weChatPayResult", "Fail")
                }
                -2 -> {
                    // -2用户取消 无需处理。发生场景：用户不支付了，点击取消，返回APP。
                    channel?.invokeMethod("weChatPayResult", "Cancel")
                }
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    }

    override fun onCancel(arguments: Any?) {
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "weChatInit" -> {
                val appId: String = call.argument("appId") ?: ""
                if (appId.isNotEmpty()) {
                    val msgApi = WXAPIFactory.createWXAPI(context, null)
                    msgApi.registerApp(appId)
                }
            }
            "weChatPay" -> {
                val request = PayReq()
                request.appId = call.argument("appId")
                request.partnerId = call.argument("partnerId")
                request.prepayId = call.argument("prepayId")
                request.packageValue = call.argument("packageValue")
                request.nonceStr = call.argument("nonceStr")
                request.timeStamp = call.argument("timeStamp")
                request.sign = call.argument("sign")
                request.extData = call.argument("extData")
                if (request.checkArgs()) {
                    val api = WXAPIFactory.createWXAPI(context, null)
                    api.sendReq(request)
                } else {
                    // 参数验证失败视为支付失败
                    channel?.invokeMethod("weChatPayResult", "Fail")
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}

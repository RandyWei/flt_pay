package dev.bughub.plugin.flt_pay_wechat

import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelpay.PayReq
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FltPayWechatPlugin : FlutterPlugin, MethodCallHandler,
    EventChannel.StreamHandler {

    private lateinit var binding: FlutterPlugin.FlutterPluginBinding

    companion object {
        var channel: MethodChannel? = null

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
                    val msgApi = WXAPIFactory.createWXAPI(this.binding.applicationContext, null)
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
                    val api = WXAPIFactory.createWXAPI(this.binding.applicationContext, null)
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

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        channel = MethodChannel(binding.binaryMessenger, "flt_pay_wechat")
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}

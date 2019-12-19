package dev.bughub.plugin.flt_pay_ali

import android.app.Activity
import com.alipay.sdk.app.PayTask
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.lang.ref.WeakReference

class FltPayAliPlugin(activity: Activity) : MethodCallHandler {
    private val weakActivity: WeakReference<Activity> = WeakReference(activity)

    companion object {
        var channel: MethodChannel? = null
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            channel = MethodChannel(registrar.messenger(), "flt_pay_ali")
            channel?.setMethodCallHandler(FltPayAliPlugin(registrar.activity()))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "aliPay" -> {
                val payInfo = call.argument<String>("payInfo") ?: ""
                GlobalScope.launch {
                    weakActivity.get()?.let { activity ->
                        val payResult = withContext(Dispatchers.Default) { PayTask(activity).payV2(payInfo, true) }
                        when (payResult["resultStatus"]) {
                            "9000" -> {
                                // 订单支付成功
                                result.success("Success")
                            }
                            "6001" -> {
                                // 用户中途取消
                                result.success("Cancel")
                            }
                            else -> {
                                // 8000	正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
                                // 4000	订单支付失败
                                // 5000	重复请求
                                // 6002	网络连接出错
                                // 6004	支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
                                // 其它	其它支付错误
                                result.success("Fail")
                            }
                        }
                    }
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}

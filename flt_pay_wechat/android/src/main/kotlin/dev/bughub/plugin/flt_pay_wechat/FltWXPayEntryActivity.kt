package dev.bughub.plugin.flt_pay_wechat

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.tencent.mm.opensdk.constants.ConstantsAPI
import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler
import com.tencent.mm.opensdk.openapi.WXAPIFactory

/**
 * 微信支付结果回调
 * Created by LSC on 2019-12-03.
 */
abstract class FltWXPayEntryActivity : Activity(), IWXAPIEventHandler {
    private var api: IWXAPI? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        api = WXAPIFactory.createWXAPI(this, null)
        api?.handleIntent(intent, this)
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        api?.handleIntent(intent, this)
    }

    override fun onResp(resp: BaseResp?) {
        resp?.let {
            if (resp.type == ConstantsAPI.COMMAND_PAY_BY_WX) {
                FltPayWechatPlugin.handlePayResponse(resp)
            }
        }
        finish()
    }

    override fun onReq(req: BaseReq?) {
    }
}
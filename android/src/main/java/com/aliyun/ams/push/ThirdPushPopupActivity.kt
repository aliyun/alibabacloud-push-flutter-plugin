package com.aliyun.ams.push

import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import com.alibaba.sdk.android.push.AndroidPopupActivity


class ThirdPushPopupActivity: AndroidPopupActivity() {
    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
    }
    /**
     * 弹窗消息打开互调。辅助弹窗通知被点击时,此回调会被调用,用户可以从该回调中获取相关参数进行下一步处理
     * @param title
     * @param content
     * @param extraMap
     * */
    override fun onSysNoticeOpened(title: String?, summary: String?, extraMap: MutableMap<String, String>?) {
        try {
//            val engine: FlutterActivity.CachedEngineIntentBuilder =
//                FlutterActivity.CachedEngineIntentBuilder(MainActivity::class.java, "my_engine_id")
//            val intent: Intent = engine.build(this)
//            startActivity(intent)
//            NotifyChannelUtils.onSysNoticeOpened(title, summary, extraMap)
            val arguments: Map<String, Object> = HashMap()
            arguments.put("title", title)
            arguments.put("summary", summary)
            arguments.put("extraMap", extraMap)
            AliyunPushPlugin.sInstance.callFlutterMethod("onNotificationOpened", arguments)
            finish()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onNotPushData(intent: Intent?) {
        super.onNotPushData(intent)
        Log.i("AndroidPopup",  "intent:"+intent.toString());
    }

    override fun onParseFailed(intent: Intent?) {
        super.onParseFailed(intent)
        Log.i("AndroidPopup","onParseFailed");
    }
}
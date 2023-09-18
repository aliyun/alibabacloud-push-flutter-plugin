package com.aliyun.ams.push;

import java.util.HashMap;
import java.util.Map;

import com.alibaba.sdk.android.push.MessageReceiver;
import com.alibaba.sdk.android.push.notification.CPushMessage;
import com.alibaba.sdk.android.push.notification.NotificationConfigure;
import com.alibaba.sdk.android.push.notification.PushData;

import android.app.Notification;
import android.content.Context;
import android.util.Log;
import androidx.core.app.NotificationCompat;

/**
 * @author wangyun
 * @date 2023/1/12
 */

public class AliyunPushMessageReceiver extends MessageReceiver {

	// 消息接收部分的LOG_TAG
	public static final String REC_TAG = "MPS:receiver";

	@Override
	public NotificationConfigure hookNotificationBuild() {
		return new NotificationConfigure() {
			@Override
			public void configBuilder(Notification.Builder builder, PushData pushData) {
				AliyunPushLog.e(REC_TAG, "configBuilder");
			}

			@Override
			public void configBuilder(NotificationCompat.Builder builder, PushData pushData) {
				AliyunPushLog.e(REC_TAG, "configBuilder");
			}

			@Override
			public void configNotification(Notification notification, PushData pushData) {
				AliyunPushLog.e(REC_TAG, "configNotification");
			}
		};
	}

	@Override
	public boolean showNotificationNow(Context context, Map<String, String> map) {
		for (Map.Entry<String, String> entry : map.entrySet()) {
			AliyunPushLog.e(REC_TAG, "key " + entry.getKey() + " value " + entry.getValue());
		}

		return super.showNotificationNow(context, map);
	}

	/**
	 * 推送通知的回调方法
	 *
	 * @param context
	 * @param title
	 * @param summary
	 * @param extraMap
	 */
	@Override
	public void onNotification(Context context, String title, String summary,
							   Map<String, String> extraMap) {
		Map<String, Object> arguments = new HashMap<>();
		if (null != extraMap) {
			arguments.putAll(extraMap);
		} else {
		}

		AliyunPushPlugin.sInstance.callFlutterMethod("onNotification", arguments);
	}

	/**
	 * 应用处于前台时通知到达回调。注意:该方法仅对自定义样式通知有效,相关详情请参考https://help.aliyun.com/document_detail/30066
	 * .html?spm=5176.product30047.6.620.wjcC87#h3-3-4-basiccustompushnotification-api
	 *
	 * @param context
	 * @param title
	 * @param summary
	 * @param extraMap
	 * @param openType
	 * @param openActivity
	 * @param openUrl
	 */
	@Override
	protected void onNotificationReceivedInApp(Context context, String title, String summary,
											   Map<String, String> extraMap, int openType,
											   String openActivity, String openUrl) {
		Map<String, Object> arguments = new HashMap<>();
		if (extraMap != null && !extraMap.isEmpty()) {
			arguments.putAll(extraMap);
		}
		arguments.put("title", title);
		arguments.put("summary", summary);
		arguments.put("openType", openType);
		arguments.put("openActivity", openActivity);
		arguments.put("openUrl", openUrl);
		AliyunPushPlugin.sInstance.callFlutterMethod("onNotificationReceivedInApp", arguments);
	}

	/**
	 * 推送消息的回调方法
	 *
	 * @param context
	 * @param cPushMessage
	 */
	@Override
	public void onMessage(Context context, CPushMessage cPushMessage) {
		Map<String, Object> arguments = new HashMap<>();
		arguments.put("title", cPushMessage.getTitle());
		arguments.put("content", cPushMessage.getContent());
		arguments.put("msgId", cPushMessage.getMessageId());
		arguments.put("appId", cPushMessage.getAppId());
		arguments.put("traceInfo", cPushMessage.getTraceInfo());
		AliyunPushPlugin.sInstance.callFlutterMethod("onMessage", arguments);
	}

	/**
	 * 从通知栏打开通知的扩展处理
	 *
	 * @param context
	 * @param title
	 * @param summary
	 * @param extraMap
	 */
	@Override
	public void onNotificationOpened(Context context, String title, String summary,
									 String extraMap) {
		Map<String, Object> arguments = new HashMap<>();
		arguments.put("title", title);
		arguments.put("summary", summary);
		arguments.put("extraMap", extraMap);
		AliyunPushPlugin.sInstance.callFlutterMethod("onNotificationOpened", arguments);
	}

	/**
	 * 通知删除回调
	 *
	 * @param context
	 * @param messageId
	 */
	@Override
	public void onNotificationRemoved(Context context, String messageId) {
		Map<String, Object> arguments = new HashMap<>();
		arguments.put("msgId", messageId);
		AliyunPushPlugin.sInstance.callFlutterMethod("onNotificationRemoved", arguments);
	}

	/**
	 * 无动作通知点击回调。当在后台或阿里云控制台指定的通知动作为无逻辑跳转时,
	 * 通知点击回调为onNotificationClickedWithNoAction而不是onNotificationOpened
	 *
	 * @param context
	 * @param title
	 * @param summary
	 * @param extraMap
	 */
	@Override
	protected void onNotificationClickedWithNoAction(Context context, String title, String summary
		, String extraMap) {
		Map<String, Object> arguments = new HashMap<>();
		arguments.put("title", title);
		arguments.put("summary", summary);
		arguments.put("extraMap", extraMap);
		AliyunPushPlugin.sInstance.callFlutterMethod("onNotificationClickedWithNoAction", arguments);
	}
}
package com.aliyun.ams.push;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.alibaba.sdk.android.push.CloudPushService;
import com.alibaba.sdk.android.push.CommonCallback;
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory;

import android.app.Activity;
import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationChannelGroup;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.media.AudioAttributes;
import android.net.Uri;
import android.os.Build;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationManagerCompat;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * PushPlugin
 */
public class AliyunPushPlugin implements FlutterPlugin, MethodCallHandler {

	private static final String TAG = "MPS:PushPlugin";

	private static final String CODE_SUCCESS = "10000";
	private static final String CODE_PARAM_ILLEGAL = "10001";
	private static final String CODE_FAILED = "10002";
	private static final String CODE_NOT_SUPPORT = "10005";

	private static final String CODE_KEY = "code";
	private static final String ERROR_MSG_KEY = "errorMsg";

	private MethodChannel channel;
	private Context mContext;

	public static AliyunPushPlugin sInstance;

	public AliyunPushPlugin() {
		sInstance = this;
	}

	public void callFlutterMethod(String method, Map<String, Object> arguments) {
		if (TextUtils.isEmpty(method)) {
			return;
		}

		Handler handler = new Handler(Looper.getMainLooper());
		handler.post(() -> channel.invokeMethod(method, arguments));
	}

	@Override
	public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
		channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "aliyun_push");
		channel.setMethodCallHandler(this);
		mContext = flutterPluginBinding.getApplicationContext();
	}

	@Override
	public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
		String methodName = call.method;
		if ("initPush".equals(methodName)) {
			initPush(result);
		} else if ("initThirdPush".equals(methodName)) {
			initThirdPush(result);
		} else if ("getDeviceId".equals(methodName)) {
			getDeviceId(result);
		} else if ("closePushLog".equals(methodName)) {
			closePushLog(result);
		} else if ("setLogLevel".equals(methodName)) {
			setLogLevel(call, result);
		} else if ("bindAccount".equals(methodName)) {
			bindAccount(call, result);
		} else if ("unbindAccount".equals(methodName)) {
			unbindAccount(result);
		} else if ("addAlias".equals(methodName)) {
			addAlias(call, result);
		} else if ("removeAlias".equals(methodName)) {
			removeAlias(call, result);
		} else if ("listAlias".equals(methodName)) {
			listAlias(result);
		} else if ("bindTag".equals(methodName)) {
			bindTag(call, result);
		} else if ("unbindTag".equals(methodName)) {
			unbindTag(call, result);
		} else if ("listTags".equals(methodName)) {
			listTags(call, result);
		} else if ("bindPhoneNumber".equals(methodName)) {
			bindPhoneNumber(call, result);
		} else if ("unbindPhoneNumber".equals(methodName)) {
			unbindPhoneNumber(result);
		} else if ("setNotificationInGroup".equals(methodName)) {
			setNotificationInGroup(call, result);
		} else if ("clearNotifications".equals(methodName)) {
			clearNotifications(result);
		} else if ("createChannel".equals(methodName)) {
			createChannel(call, result);
		} else if ("createGroup".equals(methodName)) {
			createGroup(call, result);
		} else if ("isNotificationEnabled".equals(methodName)) {
			try {
				isNotificationEnabled(call, result);
			} catch (Exception e) {
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		} else if ("jumpToNotificationSettings".equals(methodName)) {
			if (VERSION.SDK_INT >= VERSION_CODES.O) {
				jumpToAndroidNotificationSettings(call);
			}
		} else if ("setPluginLogEnabled".equals(methodName)) {
			Boolean enabled = call.argument("enabled");
			if (enabled != null) {
				AliyunPushLog.setLogEnabled(enabled);
			}
		} else {
			result.notImplemented();
		}
	}

	@Override
	public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
		channel.setMethodCallHandler(null);
	}

	private void initPush(Result result) {
		PushServiceFactory.init(mContext);
		final CloudPushService pushService = PushServiceFactory.getCloudPushService();
		pushService.setLogLevel(CloudPushService.LOG_DEBUG);
		pushService.register(mContext, new CommonCallback() {
			@Override
			public void onSuccess(String response) {
				HashMap<String, String> map = new HashMap<>();
				map.put(CODE_KEY, CODE_SUCCESS);
				try {
					result.success(map);
				} catch (Exception e) {
					AliyunPushLog.e(TAG, Log.getStackTraceString(e));
				}
			}

			@Override
			public void onFailed(String errorCode, String errorMessage) {
				HashMap<String, String> map = new HashMap<>();
				map.put(CODE_KEY, errorCode);
				map.put(ERROR_MSG_KEY, errorMessage);
				try {
					result.success(map);
				} catch (Exception e) {
					AliyunPushLog.e(TAG, Log.getStackTraceString(e));
				}
			}
		});
		pushService.turnOnPushChannel(new CommonCallback() {
			@Override
			public void onSuccess(String s) {

			}

			@Override
			public void onFailed(String s, String s1) {

			}
		});
	}

	private void initThirdPush(Result result) {

		HashMap<String, String> map = new HashMap<>();
		Context context = mContext.getApplicationContext();
		if (context instanceof Application) {
			Application application = (Application)context;
			AliyunThirdPushUtils.registerHuaweiPush(application);
			AliyunThirdPushUtils.registerXiaoMiPush(application);
			AliyunThirdPushUtils.registerVivoPush(application);
			AliyunThirdPushUtils.registerOppoPush(application);
			AliyunThirdPushUtils.registerMeizuPush(application);
			AliyunThirdPushUtils.registerGCM(application);
			AliyunThirdPushUtils.registerHonorPush(application);

			map.put(CODE_KEY, CODE_SUCCESS);
		} else {
			map.put(CODE_KEY, CODE_FAILED);
			map.put(ERROR_MSG_KEY, "context is not Application");
		}

		try {
			result.success(map);
		} catch (Exception e) {
			AliyunPushLog.e(TAG, Log.getStackTraceString(e));
		}
	}

	private void closePushLog(Result result) {
		CloudPushService service = PushServiceFactory.getCloudPushService();
		service.setLogLevel(CloudPushService.LOG_OFF);
		HashMap<String, String> map = new HashMap<>();
		map.put(CODE_KEY, CODE_SUCCESS);
		try {
			result.success(map);
		} catch (Exception e) {
			AliyunPushLog.e(TAG, Log.getStackTraceString(e));
		}
	}

	private void getDeviceId(Result result) {
		final CloudPushService pushService = PushServiceFactory.getCloudPushService();
		String deviceId = pushService.getDeviceId();
		try {
			result.success(deviceId);
		} catch (Exception e) {
			AliyunPushLog.e(TAG, Log.getStackTraceString(e));
		}
	}

	private void setLogLevel(MethodCall call, Result result) {
		Integer level = call.argument("level");
		HashMap<String, String> map = new HashMap<>();
		if (level != null) {
			final CloudPushService pushService = PushServiceFactory.getCloudPushService();
			pushService.setLogLevel(level);
			map.put(CODE_KEY, CODE_SUCCESS);
		} else {
			map.put(CODE_KEY, CODE_PARAM_ILLEGAL);
			map.put(ERROR_MSG_KEY, "Log level is empty");
		}
		try {
			result.success(map);
		} catch (Exception e) {
			AliyunPushLog.e(TAG, Log.getStackTraceString(e));
		}
	}

	private void bindAccount(MethodCall call, Result result) {
		String account = call.argument("account");
		HashMap<String, String> map = new HashMap<>();
		if (TextUtils.isEmpty(account)) {
			map.put(CODE_KEY, CODE_PARAM_ILLEGAL);
			map.put(ERROR_MSG_KEY, "account can not be empty");
			try {
				result.success(map);
			} catch (Exception e) {
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		} else {
			final CloudPushService pushService = PushServiceFactory.getCloudPushService();
			pushService.bindAccount(account, new CommonCallback() {
				@Override
				public void onSuccess(String response) {
					map.put(CODE_KEY, CODE_SUCCESS);
					try {
						result.success(map);
					} catch (Exception e) {
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}

				@Override
				public void onFailed(String errorCode, String errorMsg) {
					map.put(CODE_KEY, errorCode);
					map.put(ERROR_MSG_KEY, errorMsg);
					try {
						result.success(map);
					} catch (Exception e){
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}
			});
		}
	}

	private void unbindAccount(Result result) {
		HashMap<String, String> map = new HashMap<>();
		final CloudPushService pushService = PushServiceFactory.getCloudPushService();
		pushService.unbindAccount(new CommonCallback() {
			@Override
			public void onSuccess(String response) {
				map.put(CODE_KEY, CODE_SUCCESS);
				try {
					result.success(map);
				} catch (Exception e) {
					AliyunPushLog.e(TAG, Log.getStackTraceString(e));
				}
			}

			@Override
			public void onFailed(String errorCode, String errorMsg) {
				map.put(CODE_KEY, errorCode);
				map.put(ERROR_MSG_KEY, errorMsg);
				try {
					result.success(map);
				} catch (Exception e) {
					AliyunPushLog.e(TAG, Log.getStackTraceString(e));
				}
			}
		});
	}

	private void addAlias(MethodCall call, Result result) {
		HashMap<String, String> map = new HashMap<>();
		String alias = call.argument("alias");
		if (TextUtils.isEmpty(alias)) {
			map.put(CODE_KEY, CODE_PARAM_ILLEGAL);
			map.put(ERROR_MSG_KEY, "alias can not be empty");
			try {
				result.success(map);
			} catch (Exception e){
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		} else {
			final CloudPushService pushService = PushServiceFactory.getCloudPushService();
			pushService.addAlias(alias, new CommonCallback() {
				@Override
				public void onSuccess(String response) {
					map.put(CODE_KEY, CODE_SUCCESS);
					try {
						result.success(map);
					} catch (Exception e) {
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}

				@Override
				public void onFailed(String errorCode, String errorMsg) {
					map.put(CODE_KEY, errorCode);
					map.put(ERROR_MSG_KEY, errorMsg);
					try {
						result.success(map);
					} catch (Exception e) {
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}
			});
		}
	}

	private void removeAlias(MethodCall call, Result result) {
		HashMap<String, String> map = new HashMap<>();
		String alias = call.argument("alias");
		if (TextUtils.isEmpty(alias)) {
			map.put(CODE_KEY, CODE_PARAM_ILLEGAL);
			map.put(ERROR_MSG_KEY, "alias can not be empty");
			try {
				result.success(map);
			} catch (Exception e){
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		} else {
			final CloudPushService pushService = PushServiceFactory.getCloudPushService();
			pushService.removeAlias(alias, new CommonCallback() {
				@Override
				public void onSuccess(String response) {
					map.put(CODE_KEY, CODE_SUCCESS);
					try {
						result.success(map);
					} catch (Exception e){
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}

				@Override
				public void onFailed(String errorCode, String errorMsg) {
					map.put(CODE_KEY, errorCode);
					map.put(ERROR_MSG_KEY, errorMsg);
					try {
						result.success(map);
					} catch (Exception e) {
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}
			});
		}
	}

	private void listAlias(Result result) {
		HashMap<String, String> map = new HashMap<>();
		final CloudPushService pushService = PushServiceFactory.getCloudPushService();
		pushService.listAliases(new CommonCallback() {
			@Override
			public void onSuccess(String response) {
				map.put(CODE_KEY, CODE_SUCCESS);
				map.put("aliasList", response);
				try {
					result.success(map);
				} catch (Exception e) {
					AliyunPushLog.e(TAG, Log.getStackTraceString(e));
				}
			}

			@Override
			public void onFailed(String errorCode, String errorMsg) {
				map.put(CODE_KEY, errorCode);
				map.put(ERROR_MSG_KEY, errorMsg);
				try {
					result.success(map);
				} catch (Exception e) {
					AliyunPushLog.e(TAG, Log.getStackTraceString(e));
				}
			}
		});
	}

	private void bindTag(MethodCall call, Result result) {
		List<String> tags = call.argument("tags");
		HashMap<String, String> map = new HashMap<>();
		if (tags == null || tags.isEmpty()) {
			map.put(CODE_KEY, CODE_PARAM_ILLEGAL);
			map.put(ERROR_MSG_KEY, "tags can not be empty");
			try {
				result.success(map);
			} catch (Exception e) {
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		} else {
			Integer target = call.argument("target");
			if (target == null) {
				//默认本设备
				target = 1;
			}
			String alias = call.argument("alias");
			String[] tagsArray = new String[tags.size()];
			tagsArray = tags.toArray(tagsArray);
			final CloudPushService pushService = PushServiceFactory.getCloudPushService();
			pushService.bindTag(target, tagsArray, alias, new CommonCallback() {
				@Override
				public void onSuccess(String response) {
					map.put(CODE_KEY, CODE_SUCCESS);
					try {
						result.success(map);
					} catch (Exception e) {
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}

				@Override
				public void onFailed(String errorCode, String errorMsg) {
					map.put(CODE_KEY, errorCode);
					map.put(ERROR_MSG_KEY, errorMsg);
					try {
						result.success(map);
					} catch (Exception e) {
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}
			});
		}
	}

	private void unbindTag(MethodCall call, Result result) {
		List<String> tags = call.argument("tags");
		HashMap<String, String> map = new HashMap<>();
		if (tags == null || tags.isEmpty()) {
			map.put(CODE_KEY, CODE_PARAM_ILLEGAL);
			map.put(ERROR_MSG_KEY, "tags can not be empty");
			try {
				result.success(map);
			} catch (Exception e) {
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		} else {
			Integer target = call.argument("target");
			if (target == null) {
				//默认本设备
				target = 1;
			}
			String alias = call.argument("alias");
			String[] tagsArray = new String[tags.size()];
			tagsArray = tags.toArray(tagsArray);
			final CloudPushService pushService = PushServiceFactory.getCloudPushService();
			pushService.unbindTag(target, tagsArray, alias, new CommonCallback() {
				@Override
				public void onSuccess(String response) {
					map.put(CODE_KEY, CODE_SUCCESS);
					try {
						result.success(map);
					} catch (Exception e) {
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}

				@Override
				public void onFailed(String errorCode, String errorMsg) {
					map.put(CODE_KEY, errorCode);
					map.put(ERROR_MSG_KEY, errorMsg);
					try {
						result.success(map);
					} catch (Exception e) {
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}
			});
		}
	}

	private void listTags(MethodCall call, Result result) {
		Integer target = call.argument("target");
		if (target == null) {
			//默认本设备
			target = 1;
		}
		HashMap<String, String> map = new HashMap<>();
		final CloudPushService pushService = PushServiceFactory.getCloudPushService();
		pushService.listTags(target, new CommonCallback() {
			@Override
			public void onSuccess(String response) {
				map.put(CODE_KEY, CODE_SUCCESS);
				map.put("tagsList", response);
				try {
					result.success(map);
				} catch (Exception e) {
					AliyunPushLog.e(TAG, Log.getStackTraceString(e));
				}
			}

			@Override
			public void onFailed(String errorCode, String errorMsg) {
				map.put(CODE_KEY, errorCode);
				map.put(ERROR_MSG_KEY, errorMsg);
				try {
					result.success(map);
				} catch (Exception e) {
					AliyunPushLog.e(TAG, Log.getStackTraceString(e));
				}
			}
		});
	}

	private void bindPhoneNumber(MethodCall call, Result result) {
		HashMap<String, String> map = new HashMap<>();
		String phone = call.argument("phone");
		if (TextUtils.isEmpty(phone)) {
			map.put(CODE_KEY, CODE_PARAM_ILLEGAL);
			map.put(ERROR_MSG_KEY, "phone number can not be empty");
			try {
				result.success(map);
			} catch (Exception e) {
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		} else {
			final CloudPushService pushService = PushServiceFactory.getCloudPushService();
			pushService.bindPhoneNumber(phone, new CommonCallback() {
				@Override
				public void onSuccess(String response) {
					map.put(CODE_KEY, CODE_SUCCESS);
					try {
						result.success(map);
					} catch (Exception e) {
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}

				@Override
				public void onFailed(String errorCode, String errorMsg) {
					map.put(CODE_KEY, errorCode);
					map.put(ERROR_MSG_KEY, errorMsg);
					try {
						result.success(map);
					} catch (Exception e) {
						AliyunPushLog.e(TAG, Log.getStackTraceString(e));
					}
				}
			});
		}
	}

	private void unbindPhoneNumber(Result result) {
		HashMap<String, String> map = new HashMap<>();

		final CloudPushService pushService = PushServiceFactory.getCloudPushService();
		pushService.unbindPhoneNumber(new CommonCallback() {
			@Override
			public void onSuccess(String response) {
				map.put(CODE_KEY, CODE_SUCCESS);
				try {
					result.success(map);
				} catch (Exception e) {
					AliyunPushLog.e(TAG, Log.getStackTraceString(e));
				}
			}

			@Override
			public void onFailed(String errorCode, String errorMsg) {
				map.put(CODE_KEY, errorCode);
				map.put(ERROR_MSG_KEY, errorMsg);
				try {
					result.success(map);
				} catch (Exception e) {
					AliyunPushLog.e(TAG, Log.getStackTraceString(e));
				}
			}
		});
	}

	private void setNotificationInGroup(MethodCall call, Result result) {
		Boolean inGroup = call.argument("inGroup");
		if (inGroup == null) {
			inGroup = false;
		}
		final CloudPushService pushService = PushServiceFactory.getCloudPushService();
		pushService.setNotificationShowInGroup(inGroup);
		HashMap<String, String> map = new HashMap<>();
		map.put(CODE_KEY, CODE_SUCCESS);
		try {
			result.success(map);
		} catch (Exception e) {
			AliyunPushLog.e(TAG, Log.getStackTraceString(e));
		}
	}

	private void clearNotifications(Result result) {
		final CloudPushService pushService = PushServiceFactory.getCloudPushService();
		pushService.clearNotifications();
		HashMap<String, String> map = new HashMap<>();
		map.put(CODE_KEY, CODE_SUCCESS);
		try {
			result.success(map);
		} catch (Exception e) {
			AliyunPushLog.e(TAG, Log.getStackTraceString(e));
		}
	}

	private void createChannel(MethodCall call, Result result) {
		HashMap<String, String> map = new HashMap<>();
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

			String id = call.argument("id");
			String name = call.argument("name");
			Integer importance = call.argument("importance");
			String desc = call.argument("desc");
			String groupId = call.argument("groupId");
			Boolean allowBubbles = call.argument("allowBubbles");
			Boolean light = call.argument("light");
			Integer color = call.argument("lightColor");
			Boolean showBadge = call.argument("showBadge");
			String soundPath = call.argument("soundPath");
			Integer soundUsage = call.argument("soundUsage");
			Integer soundContentType = call.argument("soundContentType");
			Integer soundFlag = call.argument("soundFlag");
			Boolean vibration = call.argument("vibration");
			List<Long> vibrationPattern = call.argument("vibrationPattern");

			NotificationManager notificationManager
				= (NotificationManager)mContext.getSystemService(Context.NOTIFICATION_SERVICE);
			int importanceValue;
			if (importance == null) {
				importanceValue = NotificationManager.IMPORTANCE_DEFAULT;
			} else {
				importanceValue = importance;
			}
			NotificationChannel channel = new NotificationChannel(id, name, importanceValue);
			channel.setDescription(desc);
			if (groupId != null) {
				channel.setGroup(groupId);
			}
			if (allowBubbles != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
				channel.setAllowBubbles(allowBubbles);
			}
			if (light != null) {
				channel.enableLights(light);
			}
			if (color != null) {
				channel.setLightColor(color);
			}
			if (showBadge != null) {
				channel.setShowBadge(showBadge);
			}
			if (!TextUtils.isEmpty(soundPath)) {
				File file = new File(soundPath);
				if (file.exists() && file.canRead() && file.isFile()) {
					if (soundUsage == null) {
						channel.setSound(Uri.fromFile(file), null);
					} else {
						AudioAttributes.Builder builder = new AudioAttributes.Builder()
							.setUsage(soundUsage);
						if (soundContentType != null) {
							builder.setContentType(soundContentType);
						}
						if (soundFlag != null) {
							builder.setFlags(soundFlag);
						}
						channel.setSound(Uri.fromFile(file), builder.build());
					}
				}
			}
			if (vibration != null) {
				channel.enableVibration(vibration);
			}
			if (vibrationPattern != null && vibrationPattern.size() > 0) {
				long[] pattern = new long[vibrationPattern.size()];
				for (int i = 0; i < vibrationPattern.size(); i++) {
					pattern[i] = vibrationPattern.get(i);
				}
				channel.setVibrationPattern(pattern);
			}
			notificationManager.createNotificationChannel(channel);
			map.put(CODE_KEY, CODE_SUCCESS);
			try {
				result.success(map);
			} catch (Exception e) {
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		} else {
			map.put(CODE_KEY, CODE_NOT_SUPPORT);
			map.put(ERROR_MSG_KEY,
				"Android version is below Android O which is not support create channel");
			try {
				result.success(map);
			} catch (Exception e) {
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		}
	}

	private void createGroup(MethodCall call, Result result) {
		HashMap<String, String> map = new HashMap<>();
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

			String id = call.argument("id");
			String name = call.argument("name");
			String desc = call.argument("desc");

			NotificationManager notificationManager
				= (NotificationManager)mContext.getSystemService(Context.NOTIFICATION_SERVICE);
			NotificationChannelGroup group = new NotificationChannelGroup(id, name);
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
				group.setDescription(desc);
			}
			notificationManager.createNotificationChannelGroup(group);
			map.put(CODE_KEY, CODE_SUCCESS);
			try {
				result.success(map);
			} catch (Exception e) {
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		} else {
			map.put(CODE_KEY, CODE_NOT_SUPPORT);
			map.put(ERROR_MSG_KEY,
				"Android version is below Android O which is not support create group");
			try {
				result.success(map);
			} catch (Exception e) {
				AliyunPushLog.e(TAG, Log.getStackTraceString(e));
			}
		}
	}

	private void isNotificationEnabled(MethodCall call, Result result) {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			NotificationManager manager = (NotificationManager)mContext.getSystemService(
				Context.NOTIFICATION_SERVICE);
			if (!manager.areNotificationsEnabled()) {
				result.success(false);
				return;
			}
			String id = call.argument("id");
			if (id == null) {
				result.success(true);
				return;
			}
			List<NotificationChannel> channels = manager.getNotificationChannels();
			for (NotificationChannel channel : channels) {
				if (channel.getId().equals(id)) {
					if (channel.getImportance() == NotificationManager.IMPORTANCE_NONE) {
						result.success(false);
					} else {
						if (channel.getGroup() != null) {
							if (android.os.Build.VERSION.SDK_INT
								>= android.os.Build.VERSION_CODES.P) {
								NotificationChannelGroup group
									= manager.getNotificationChannelGroup(channel.getGroup());
								result.success(!group.isBlocked());
								return;
							}
						}
						result.success(true);
						return;
					}
				}
			}
			// channel 未定义，返回false
			result.success(false);
		} else {
			boolean enabled = NotificationManagerCompat.from(mContext).areNotificationsEnabled();
			result.success(enabled);
		}
	}

	@RequiresApi(api = VERSION_CODES.O)
	private void jumpToAndroidNotificationSettings(MethodCall call) {
		String id = call.argument("id");
		Intent intent;
		if (id != null) {
			intent = new Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS);
			intent.putExtra(Settings.EXTRA_APP_PACKAGE, mContext.getPackageName());
			intent.putExtra(Settings.EXTRA_CHANNEL_ID, id);
		} else {
			// 跳转到应用的通知设置界面
			intent = new Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS);
			intent.putExtra(Settings.EXTRA_APP_PACKAGE, mContext.getPackageName());
		}
		if (!(mContext instanceof Activity)) {
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		}
		mContext.startActivity(intent);
	}

}

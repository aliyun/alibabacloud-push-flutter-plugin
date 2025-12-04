# Aliyun Push Flutter Plugin

## 1. 项目简介

本库（`aliyun_push`）是一个 Flutter 推送通知插件，旨在简化 Android 和 iOS 平台集成阿里云推送服务的过程。通过封装原生阿里云推送 SDK (Android: `alicloud-android-push`, iOS: `AlicloudPush`)，开发者可以更便捷地在 Flutter 应用中实现稳定、高效的推送通知功能，而无需深入了解原生平台的复杂配置。本库致力于提供一致的 dart API，降低跨平台开发的难度，提升开发效率。

## 2. 特性

- 🚀 **跨平台支持**：一套代码同时支持 Android 和 iOS 平台。
- 🔔 **阿里云推送**：深度集成阿里云官方推送 SDK，保证推送服务的稳定性和可靠性。
- 🔧 **简化接入**：封装原生复杂配置，提供简洁易用的 dart API。
- 🎯 **消息处理**：支持接收和处理通知栏消息及应用内消息。
- 🔌 **易于扩展**：未来可根据需求扩展更多推送相关功能。

## 3. 安装步骤

在`pubspec.yaml`中加入dependencies

```yaml
dependencies:
    aliyun_push: 1.0.4
```

## 4. 插件初始化

```dart
import 'package:aliyun_push/aliyun_push.dart';

final _aliyunPush = AliyunPush();

Future<void> initAliyunPush() async {
    String appKey;
    String appSecret;
    // 配置App Key和App Secret（请在 https://emas.console.aliyun.com 获取）
    if (Platform.isIOS) {
      appKey = "填写自己iOS项目的appKey";
      appSecret = "填写自己iOS项目的appSecret";
    } else {
      appKey = "填写自己Android项目的appKey";
      appSecret = "填写自己Android项目的appSecret";
    }

    _aliyunPush
        .initPush(appKey: appKey, appSecret: appSecret)
        .then((initResult) {
      var code = initResult['code'];
      if (code == kAliyunPushSuccessCode) {
        showOkDialog("初始化推送成功");
      } else {
        String errorMsg = initResult['errorMsg'];
        showErrorDialog('初始化推送失败, errorMsg: $errorMsg}');
      }
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }
```

## 5. 原生环境配置

### 5.1 Android 配置

#### 5.1.1 配置 AndroidManifest 文件

在 `android/app/src/main/AndroidManifest.xml` 文件的 `<application>` 标签内，添加以下配置以支持多个推送通道（如华为、VIVO、荣耀、OPPO、小米、魅族及 FCM）：

```xml
<!-- 华为推送 -->
<meta-data android:name="com.huawei.hms.client.appid" android:value="YOUR_HUAWEI_APP_ID" />

<!-- VIVO 推送 -->
<meta-data android:name="com.vivo.push.api_key" android:value="YOUR_VIVO_API_KEY" />
<meta-data android:name="com.vivo.push.app_id" android:value="YOUR_VIVO_APP_ID" />

<!-- 荣耀推送 -->
<meta-data android:name="com.hihonor.push.app_id" android:value="YOUR_HIHONOR_APP_ID" />

<!-- OPPO 推送 -->
<meta-data android:name="com.oppo.push.key" android:value="YOUR_OPPO_KEY" />
<meta-data android:name="com.oppo.push.secret" android:value="YOUR_OPPO_SECRET" />

<!-- 小米推送 -->
<meta-data android:name="com.xiaomi.push.id" android:value="YOUR_XIAOMI_APP_ID" />
<meta-data android:name="com.xiaomi.push.key" android:value="YOUR_XIAOMI_APP_KEY" />

<!-- 魅族推送 -->
<meta-data android:name="com.meizu.push.id" android:value="YOUR_MEIZU_APP_ID" />
<meta-data android:name="com.meizu.push.key" android:value="YOUR_MEIZU_APP_KEY" />

<!-- FCM 推送 -->
<meta-data android:name="com.gcm.push.sendid" android:value="YOUR_FCM_SENDER_ID" />
<meta-data android:name="com.gcm.push.applicationid" android:value="YOUR_FCM_APP_ID" />
<meta-data android:name="com.gcm.push.projectid" android:value="YOUR_FCM_PROJECT_ID" />
<meta-data android:name="com.gcm.push.api.key" android:value="YOUR_FCM_API_KEY" />

<!-- 阿里云推送消息接收器（用户可自主扩展） -->
<receiver android:name="com.aliyun.ams.push.AliyunPushMessageReceiver" android:exported="false">
    <intent-filter>
        <action android:name="com.alibaba.push2.action.NOTIFICATION_OPENED" />
    </intent-filter>
    <intent-filter>
        <action android:name="com.alibaba.push2.action.NOTIFICATION_REMOVED" />
    </intent-filter>
    <intent-filter>
        <action android:name="com.alibaba.sdk.android.push.RECEIVE" />
    </intent-filter>
</receiver>
```

**注意事项**：

- **替换参数**：将 `YOUR_XXX` 占位符替换为各推送平台提供的实际参数（如 App ID、API Key 等）。请参考[阿里云推送官方文档](https://help.aliyun.com/document_detail/434677.html)获取具体配置方法。
- **消息接收器**：本插件已内置 `AliyunPushMessageReceiver`，只需按上述模板添加 `<receiver>` 配置即可支持通知的接收和处理。
- **权限检查**：确保 `AndroidManifest.xml` 已包含必要的网络和推送相关权限（如 `<uses-permission android:name="android.permission.INTERNET" />`）。

以下3个通道配置时需要特殊处理

+ 华为通道的`com.huawei.hms.client.appid`参数值的格式是`appid=xxxx`，有个前缀`appid=`
+ 小米通道的`com.xiaomi.push.id`和`com.xiaomi.push.key`的值一般都是长数字，如果直接配置原始值，系统读取时会自动判断成long类型，但是AndroidManifest中的meta-data是不支持long类型的，这样就会造成插件读取到的值和实际值不一致，进而导致小米通道初始化失败
+ fcm通道的`com.gcm.push.sendid`值也是长数字，同样会导致插件读取时出错

解决办法：

+ 配置时在原始值前方加入`id=`，插件会自动解析并读取原始值

```xml
<application android:name="*****">
      <!-- 小米-->
      <meta-data android:name="com.xiaomi.push.id" android:value="id=2222222222222222222" />
      <meta-data android:name="com.xiaomi.push.key" android:value="id=5555555555555" />
      
      <!-- fcm -->
      <meta-data android:name="com.gcm.push.sendid" android:value="id=999999999999" />
</application>
```

#### 5.1.2 混淆配置

如果您的项目中使用Proguard等工具做了代码混淆，请保留以下配置：

```txt
-keepclasseswithmembernames class ** {
    native <methods>;
}
-keepattributes Signature
-keep class sun.misc.Unsafe { *; }
-keep class com.taobao.** {*;}
-keep class com.alibaba.** {*;}
-keep class com.alipay.** {*;}
-keep class com.ut.** {*;}
-keep class com.ta.** {*;}
-keep class anet.**{*;}
-keep class anetwork.**{*;}
-keep class org.android.spdy.**{*;}
-keep class org.android.agoo.**{*;}
-keep class android.os.**{*;}
-keep class org.json.**{*;}
-dontwarn com.taobao.**
-dontwarn com.alibaba.**
-dontwarn com.alipay.**
-dontwarn anet.**
-dontwarn org.android.spdy.**
-dontwarn org.android.agoo.**
-dontwarn anetwork.**
-dontwarn com.ut.**
-dontwarn com.ta.**
```

### 5.2 iOS 配置

#### 5.2.1 Podfile 仓库配置

打开 `ios/Podfile` 文件，在文件最上方添加阿里云仓库和官方仓库地址：

```ruby
source 'https://github.com/aliyun/aliyun-specs.git'
source 'https://github.com/CocoaPods/Specs.git'
```

然后进入 `ios` 目录执行 `pod install --repo-update`。

**注意**：iOS 工程需在 Xcode 的 TARGETS -> Build Settings -> Linking -> Other Linker Flags 中添加 `-ObjC`，否则推送服务无法正常使用。

如工程依赖多个三方库，可能因 Category 冲突导致问题。此时可用 `-force_load` 单独载入指定二进制文件，例如：

```c++
-force_load<framework_path>/CloudPushSDK.framework/CloudPushSDK
```

## 6. API 参考

本节提供插件的 API 详细参考，涵盖初始化、通用、平台特定（Android 和 iOS）以及回调事件处理接口。每个 API 均包含用途、参数、返回值和使用示例。

### 6.1 初始化相关接口

#### setLogLevel

`Future<Map<dynamic, dynamic>> setLogLevel(AliyunPushLogLevel level) async`

设置推送SDK输出日志的级别

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| level | AliyunPushLogLevel | 必须参数 |  `None`、`Debug`、`Info`、`Warn`、`Error`）。设置为 `None` 禁用日志，其他级别启用日志。|

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例：

```dart

_aliyunPush.setLogLevel(logLevel).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
        
    } else {
        var errorCode = result['code'];
        var errorMsg = result['errorMsg'];
    }      
});
```

#### `initPush`

`Future<Map<dynamic, dynamic>> initPush({String? appKey, String? appSecret}) async`

参数:

| 参数名 | 类型 | 是否必须 |
| --- | --- | ---|
| appKey | String | 可选参数 |
| appSecret | String | 可选参数 |

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例:

```dart
String appKey;
String appSecret;
if (Platform.isIOS) {
 appKey = "填写自己iOS项目的appKey";
 appSecret = "填写自己iOS项目的appSecret";
} else {
 appKey = "填写自己Android项目的appKey";
 appSecret = "填写自己Android项目的appSecret";
}

_aliyunPush.initPush(appKey: appKey, appSecret: appSecret)
        .then((initResult) {
var code = initResult['code'];
if (code == kAliyunPushSuccessCode) {
 print('Init Aliyun Push successfully');
 } else {
 String errorMsg = initResult['errorMsg'];
 print('Aliyun Push init failed, errorMsg is: $errorMsg);
}
```

### 6.2 通用接口

#### getDeviceId

`Future<String> getDeviceId()`

获取设备Id

返回值：

`String` - 设备Id

代码示例：

```dart
_aliyunPush.getDeviceId().then((deviceId) {
});
```

#### bindAccount

`Future<Map<dynamic, dynamic>> bindAccount(String account) async`

绑定账号

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| account | String | 必须参数 | 要绑定的账号 |

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码实例:

```dart
_pushPlugin.bindAccount(account).then((bindResult) {
    var code = bindResult['code'];
    if (code == kAliyunPushSuccessCode) {             
    } else {
    }
});
```

#### unbindAccount

`Future<Map<dynamic, dynamic>> unbindAccount(String account) async`

解绑账号

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码实例:

```dart
_pushPlugin.unbindAccount(account).then((unbindResult) {
    var code = unbindResult['code'];
    if (code == kAliyunPushSuccessCode) {             
    } else {
    }
});
```

#### `addAlias`

`Future<Map<dynamic, dynamic>> addAlias(String alias) async`

添加别名

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| alias | String | 必须参数 | 要添加的别名 |  

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例：

```dart
_pushPlugin.addAlias(account).then((addResult) {
    var code = addResult['code'];
    if (code == kAliyunPushSuccessCode) {             
    } else {
    }
});

```

#### `removeAlias`

`Future<Map<dynamic, dynamic>> removeAlias(String alias) async`

移除别名

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| alias | String | 必须参数 | 要移除的别名 |  

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例：

```dart
_pushPlugin.removeAlias(account).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {             
    } else {
    }
});

```

#### `listAlias`

` Future<Map<dynamic, dynamic>> listAlias() async `

查询别名

返回值：

`Map<dynamic, dynamic>`

map中包含三个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息
+ `aliasList`: 别名列表（以逗号拼接成字符串形式返回别名列表）

代码示例：

```dart
_pushPlugin.listAlias(account).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {      
    var aliasList = result['aliasList'];       
    } else {
    }
});
```

#### `bindTag`

`Future<Map<dynamic, dynamic>> bindTag(List<String> tags,{int target = kAliyunTargetDevice, String? alias}) async`

添加标签
  
参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| tags | List\<String> | 必须参数 |  要绑定的标签列表 |
| target | int | 可选参数 |  目标类型，1: 本设备  2: 本设备绑定账号  3: 别名</br>默认是1 |
| alias | String| 可选参数 | 别名（仅当target = 3时生效）

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码实例:

```dart
_pushPlugin.bindTag(tags).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {             
    } else {
    }
});
```

#### `unbindTag`

`Future<Map<dynamic, dynamic>> unbindTag(List<String> tags, {int target = kAliyunTargetDevice, String? alias}) async`

移除标签

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| tags | List\<String\> | 必须参数 |  要移除的标签列表 |
| target | int | 可选参数 |  目标类型，1: 本设备  2: 本设备绑定账号  3: 别名</br>默认是1 |
| alias | String| 可选参数 | 别名（仅当target = 3时生效）

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码实例:

```dart
_pushPlugin.unbindTag(tags).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {             
    } else {
    }
});
```

#### `listTags`

`Future<Map<dynamic, dynamic>> listTags`

查询标签列表

返回值：

`Map<dynamic, dynamic>`

map中包含三个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息
+ `tagsList`: 标签列表（以逗号拼接成字符串形式返回标签列表）

代码示例：

```dart
 _pushPlugin.listTags(account).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {      
        var tagsList = listTagsResult['tagsList'];      
    } else {
    }
});
```

### 6.3 Android 专用接口

#### `initAliyunThirdPush`

`Future<Map<dynamic, dynamic>> initAndroidThirdPush() async`

**注意：**该方法只支持Android平台

初始化辅助通道

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.initAndroidThirdPush().then((initResult) {
      var code = initResult['code'];
      if (code == kAliyunPushSuccessCode) {
        print("Init Aliyun Third Push successfully");
      } else {
        print( 'Aliyun Third Push init failed, errorMsg is: $errorMsg');
      }
    });
```

#### bindPhoneNumber

`Future<Map<dynamic, dynamic>> bindPhoneNumber(String phone) async`

绑定手机号码

> **注意：只支持Android平台**

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| phone | string | 必须参数 |  要绑定的电话号码|

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例:

```dart
_aliyunPush.bindPhoneNumber(phone).then((bindResult) {
    var code = bindResult['code'];
    if (code == kAliyunPushSuccessCode) {
                  
    } else {
        var errorCode = bindResult['code'];
        var errorMsg = bindResult['errorMsg'];             
    }
});
```

#### unbindPhoneNumber

`Future<Map<dynamic, dynamic>> unbindPhoneNumber() async`

解绑手机号码

> **注意：只支持Android平台**

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例:

```dart
_aliyunPush.unbindPhoneNumber().then((unbindResult) {
    var code = unbindResult['code'];
    if (code == kAliyunPushSuccessCode) {
                
    } else {
        var errorCode = unbindResult['code'];
        var errorMsg = unbindResult['errorMsg'];          
    }
});
```

#### setNotificationInGroup

`Future<Map<dynamic, dynamic>> setNotificationInGroup(bool inGroup) async`

设置通知分组展示

> **注意：只支持Android平台**

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| inGroup | bool | 必须参数 |  true-开启分组;false-关闭分组 |

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.setNotificationInGroup(true).then((result){
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
        print('开启通知分组展示成功');
     }
});

_aliyunPush.setNotificationInGroup(false).then((result){
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
        print('关闭通知分组展示成功');
     }
});
```

#### clearNotifications

`Future<Map<dynamic, dynamic>> clearNotifications() async`

清除所有通知

> **注意：只支持Android平台**

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例:

```dart
_aliyunPush.clearNotifications().then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {           
    }
});
```

#### createAndroidChannel

```dart
Future<Map<dynamic, dynamic>> createAndroidChannel(
      String id, String name, int importance, String description,
      {String? groupId,
      bool? allowBubbles,
      bool? light,
      int? lightColor,
      bool? showBadge,
      String? soundPath,
      int? soundUsage,
      int? soundContentType,
      int? soundFlag,
      bool? vibration,
      List<int>? vibrationPatterns})
```

创建Android平台的NotificationChannel

> **注意：只支持Android平台**

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| id | String | 必须参数 |  通道id |
| name | String |必须参数 | 通道name |
| importance | int | 必须参数 | 通道importance |
| desc | String | 必须参数 | 通道描述 |
| groupId | String | 可选参数 | - |
| allowBubbles | bool | 可选参数 | - |
| light | bool | 可选参数 | - |
| lightColor | int | 可选参数 | - |
| showBadge | bool | 可选参数 | - |
| soundPath | String | 可选参数 | - |
| soundUsage | int | 可选参数 | - |
| soundContentType | int | 可选参数 | - |
| soundFlag | int | 可选参数 | - |
| vibration | bool | 可选参数 | - |
| vibrationPatterns | List\<int> | 可选参数 | - |

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例：

```dart

_aliyunPush.createAndroidChannel(_channelController.text, '测试通道A', 3, '测试创建通知通道')
    .then((createResult) {
        var code = createResult['code'];
        if (code == kAliyunPushSuccessCode) {
            Fluttertoast.showToast(
                msg: '创建$channel通道成功', gravity: ToastGravity.CENTER);
        } else {
            var errorCode = createResult['code'];
            var errorMsg = createResult['errorMsg'];
            Fluttertoast.showToast(
                msg: '创建$channel通道失败, $errorCode - $errorMsg',
                gravity: ToastGravity.CENTER);
            }
        });
```

#### createAndroidChannelGroup

`Future<Map<dynamic, dynamic>> createAndroidChannelGroup(String id, String name, String desc) async`

创建通知通道的分组

> **注意：只支持Android平台**

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| id | String | 必须参数 |  通道id |
| name | String |必须参数 | 通道name |
| desc | String | 必须参数 | 通道描述 |

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

#### isAndroidNotificationEnabled

`Future<bool> isAndroidNotificationEnabled({String? id}) async`

检查通知状态

> **注意：只支持Android平台**

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| id | String | 可选参数 |  通道id |

返回值：

`bool` - true: 已打开; false：未打开

代码示例：

```dart
bool isEnabled = await _aliyunPush.isAndroidNotificationEnabled(
                id: 'xxx');
```

#### jumpToAndroidNotificationSettings

`void jumpToAndroidNotificationSettings({String? id})`

跳转到通知设置页面

> **注意：只支持Android平台**

代码示例:

```dart
_aliyunPush.jumpToAndroidNotificationSettings();
```

#### setAndroidBadgeNum

`Future<Map<dynamic, dynamic>> setAndroidBadgeNum(int num) async`

设置Android应用角标数量

> **注意：只支持Android平台**

参数:

| 参数名 | 类型 | 是否必须 | 含义 |
| --- | --- | ---| --- |
| num | int | 必须参数 | 要设置的角标数量 |

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

支持情况：当前接口仅支持华为、荣耀、VIVO机型

+ 华为机型：EMUI 4.1 及以上支持角标功能
+ 荣耀机型：Magic UI 6.0 版本开始支持数字角标

权限配置：
在`android/app/src/main/AndroidManifest.xml`中添加以下权限：
```xml
<!-- 华为/荣耀 Badge 需要权限 -->
<uses-permission android:name="com.hihonor.android.launcher.permission.CHANGE_BADGE" />
<uses-permission android:name="com.huawei.android.launcher.permission.CHANGE_BADGE" />

<!-- VIVO 角标需要权限 -->
<uses-permission android:name="com.vivo.notification.permission.BADGE_ICON" />
```

代码示例:

```dart
_aliyunPush.setAndroidBadgeNum(5).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
        print('设置Android角标成功');
    } else {
        var errorCode = result['code'];
        var errorMsg = result['errorMsg'];
        print('设置Android角标失败: $errorCode - $errorMsg');
    }
});
```

### 6.4 iOS 专用接口

#### setIOSBadgeNum

`Future<Map<dynamic, dynamic>> setIOSBadgeNum(int num) async`

设置角标数

> **注意：只支持iOS平台**

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.setIOSBadgeNum(badgeNum).then((result) {
    var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
            Fluttertoast.showToast(
                    msg: '设置角标个数$badgeNum成功', gravity: ToastGravity.CENTER);
        }
    });
```

#### syncIOSBadgeNum

`Future<Map<dynamic, dynamic>> syncIOSBadgeNum(int num) async`

同步角标数

> **注意：只支持iOS平台**

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.syncIOSBadgeNum(badgeNum).then((result) {
    var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
            Fluttertoast.showToast(
                    msg: '同步角标个数$badgeNum成功', gravity: ToastGravity.CENTER);
        }
    });
```

#### getApnsDeviceToken

`Future<String> getApnsDeviceToken() async`

获取APNs Token

> **注意：只支持iOS平台**

返回值：

`String` - APNs Token

代码示例：

```dart
_aliyunPush.getApnsDeviceToken().then((token) {
});
```

#### showIOSNoticeWhenForeground

`Future<Map<dynamic, dynamic>> showIOSNoticeWhenForeground(bool enable) async`

App处于前台时显示通知

> **注意：只支持iOS平台**

返回值：

`Map<dynamic, dynamic>`

map中包含两个key值:

+ `code`: 错误码
+ `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.showIOSNoticeWhenForeground(true).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
        Fluttertoast.showToast(
            msg: '设置前台显示通知成功', gravity: ToastGravity.CENTER);
    }
});
```

#### isIOSChannelOpened

`Future<bool> isIOSChannelOpened() async`

通知通道是否已打开

> **注意：只支持iOS平台**

返回值：

`bool` - true: 已打开; false：未打开

代码示例：

```dart
_aliyunPush.isIOSChannelOpened().then((opened) {
 if (opened) {          
 } else {          
 }
});
```

### 6.5 回调事件处理

#### `addMessageReceiver`

```dart
void addMessageReceiver(
      {PushCallback? onNotification,
      PushCallback? onMessage,
      PushCallback? onNotificationOpened,
      PushCallback? onNotificationRemoved,
      PushCallback? onAndroidNotificationReceivedInApp,
      PushCallback? onAndroidNotificationClickedWithNoAction,
      PushCallback? onIOSChannelOpened,
      PushCallback? onIOSRegisterDeviceTokenSuccess,
      PushCallback? onIOSRegisterDeviceTokenFailed}) 
```

注册推送相关的回调

参数:

| 参数名 | 类型 | 是否必须 | 支持平台 | 功能 |
| --- | --- | ---|  --- | --- |
| onNotification | PushCallback | 可选参数 | Android/iOS | 收到通知的回调 |
| onMessage | PushCallback | 可选参数 | Android/iOS | 收到消息的回调 |
| onNotificationOpened | PushCallback | 可选参数 | Android/iOS | 从通知栏打开通知的扩展处理 |
| onNotificationRemoved | PushCallback | 可选参数 | Android/iOS | 通知删除回调 |
| onAndroidNotificationReceivedInApp | PushCallback | 可选参数 | Android | 应用处于前台时通知到达回调 |
| onAndroidNotificationClickedWithNoAction | PushCallback | 可选参数 | Android | 无动作通知点击回调。当在后台或阿里云控制台指定的通知动作为无逻辑跳转时, 通知点击回调为onNotificationClickedWithNoAction而不是onNotificationOpened |
| onIOSChannelOpened | PushCallback | 可选参数 | iOS | 通道channel打开的回调 |
| onIOSRegisterDeviceTokenSuccess | PushCallback | 可选参数 | iOS | 注册APNs token成功回调|
| onIOSRegisterDeviceTokenFailed | PushCallback | 可选参数 | iOS | 注册APNs token失败回调|

代码示例：

```dart
_aliyunPush.addMessageReceiver(
        onNotification: _onNotification,
        onNotificationOpened: _onNotificationOpened,
        onNotificationRemoved: _onNotificationRemoved,
        onMessage: _onMessage,
        onAndroidNotificationReceivedInApp: _onAndroidNotificationReceivedInApp,
        onAndroidNotificationClickedWithNoAction:
            _onAndroidNotificationClickedWithNoAction,
        onIOSChannelOpened: _onIOSChannelOpened,
        onIOSRegisterDeviceTokenSuccess: _onIOSRegisterDeviceTokenSuccess,
        onIOSRegisterDeviceTokenFailed: _onIOSRegisterDeviceTokenFailed);
```

### 6.6 常量和类型

#### 返回值Map结构
大多数API方法返回的'Map<dynamic, dynamic>'都包含以下标准字段：
| 字段名 | 类型 | 含义
| code	| String | 错误码，成功时为"10000"
| errorMsg | String | 错误信息，成功时通常为空字符串或成功提示
部分方法可能包含额外的字段（如aliasList、tagsList等），具体请参考各方法的详细说明。

#### 结果状态码

| 名称 | 值 |  含义 |
| --- | --- | --- |
| kAliyunPushSuccessCode | "10000" | 成功 |
| kAliyunPushParamsIllegal | "10001" | 参数错误 |
| kAliyunPushFailedCode | "10002" | 通用失败码 |
| kAliyunPushOnlyAndroid | "10003" | 方法只支持Android平台|
| kAliyunPushOnlyIOS | "10004" | 方法只支持iOS平台 |
| kAliyunPushNotSupport | "10005" | 平台不支持，比如Android创建group只支持Android 8.0以上版本|

> 详细的原生SDK错误码请参考阿里云文档：[Android](https://help.aliyun.com/document_detail/434686.html), [iOS](https://help.aliyun.com/document_detail/434705.html)

#### 标签目标类型

- `kAliyunTargetDevice = 1`: 设备目标。
- `kAliyunTargetAccount = 2`: 账户目标。
- `kAliyunTargetAlias = 3`: 别名目标。

#### 类型定义

- **AliyunPushLogLevel**

```dart
enum AliyunPushLogLevel {
  none('none'),
  error('error'),
  warn('warn'),
  info('info'),
  debug('debug');

  final String value;
  const AliyunPushLogLevel(this.value);
}
```

- **PushCallback**

```dart
typedef PushCallback = Future<dynamic> Function(Map<dynamic, dynamic> message);
```

## 7. 故障排查

1.  **问题：iOS `pod install` 失败或找不到 `AlicloudPush` 模块。**

    - **解决方案：**
      1.  确保插件依赖已正确安装。
      2.  尝试执行 `pod repo update` 更新本地 CocoaPods 仓库，然后再次 `pod install`。
      3.  删除 `ios/Pods` 目录和 `ios/Podfile.lock` 文件，然后重新执行 `pod install`。

2.  **问题：收不到推送通知。**

    - **解决方案 (通用)：**
      1.  确认 AppKey 和 AppSecret (Android & iOS) 配置正确无误。
      2.  检查设备网络连接是否正常。
      3.  确认应用是否已获取到 Device ID (可以通过 API 获取并打印日志查看)。
      4.  登录阿里云推送控制台，检查推送目标是否正确，是否有错误日志。
    - **解决方案 (Android)：**
      1.  检查 `AndroidManifest.xml` 中的权限、Receiver 和 Meta-data 配置是否正确。
      2.  查看 Logcat 日志，搜索 "MPS" 或 "AliPush" 等关键词，看是否有 SDK 初始化失败或连接错误的信息。
      3.  如果使用厂商通道，确保已在阿里云控制台配置了对应厂商的参数，并且手机上安装了对应厂商的服务框架。
    - **解决方案 (iOS)：**
      1.  确认已在 Xcode 中开启 "Push Notifications" Capability。
      2.  确认推送证书 (开发/生产) 是否正确配置并上传到阿里云控制台，且未过期。
      3.  真机调试时，检查设备的通知设置，确保允许该 App 显示通知。

3.  **问题：如何在 Expo 框架中使用**

    - **解决方案：**
      1.  你需要参考[这篇文档](https://docs.expo.dev/develop/development-builds/create-a-build/)完成原生构建，并安装到调试机器替代 Expo Go 应用。

4.  **问题：点击通知后，`onNotificationOpened` 事件没有触发。**
    - **解决方案：**
      1.  **Android:** 确保在 `AndroidManifest.xml` 中注册了插件提供的 receiver 组件。

> 更多问题请参考[阿里云官网文档](https://help.aliyun.com/document_detail/434791.html)

## 8. 贡献指南

我们欢迎任何形式的贡献，包括但不限于：

- 报告 Bug (提交 Issue)
- 提交新功能建议 (提交 Issue)
- 编写或改进文档
- 提交 Pull Request (PR)

**提交 Issue：**

- 请先搜索已有的 Issue，避免重复提交。
- 清晰描述问题，提供复现步骤、环境信息 (Flutter 版本、库版本、iOS/Android 版本等) 和相关日志或截图。

**提交 Pull Request：**

1.  Fork 本仓库。
2.  基于 `master` (或当前开发分支) 创建新的特性分支。
3.  确保代码风格一致 (可以使用 Prettier, ESLint 等工具)。
4.  提交 PR 到主仓库的 `master` 分支，并清晰描述 PR 的内容和目的。

## 9. 许可证

本库采用 [MIT License](LICENSE)。

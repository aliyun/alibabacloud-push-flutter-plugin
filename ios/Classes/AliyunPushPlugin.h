#import <Flutter/Flutter.h>

static NSString* const KEY_CODE = @"code";
static NSString* const KEY_ERROR_MSG = @"errorMsg";

static NSString* const CODE_SUCCESS = @"0";
static NSString* const CODE_PARAMS_ILLEGAL = @"-1";
static NSString* const CODE_FAILED = @"-2";

@interface AliyunPushPlugin : NSObject <FlutterPlugin>
@property FlutterMethodChannel *channel;
@end


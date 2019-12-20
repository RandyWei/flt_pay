#import "FltPayWechatPlugin.h"

#import "FltWechatPay.h"

@interface FltPayWechatPlugin()
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger>* messenger;
@end

@implementation FltPayWechatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"flt_pay_wechat"
              binaryMessenger:[registrar messenger]];
    FltPayWechatPlugin* instance = [[FltPayWechatPlugin alloc] initWithRegistrar:registrar];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _messenger = [registrar messenger];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
        NSString *appid = [NSString stringWithFormat:@"%@", call.arguments[@"appid"]];
        NSString *link = [NSString stringWithFormat:@"%@", call.arguments[@"link"]];
        BOOL success = [[FltWechatPay shareInstance] registerApp:appid universalLink:link];
        result(success ? @"true" : @"false");
    }else if ([@"wachatpay" isEqualToString:call.method]) {
        FltWechatPay *wechatPay = [FltWechatPay shareInstance];
        
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"flt_pay_wechat/pay" binaryMessenger:_messenger];
        [eventChannel setStreamHandler:wechatPay];
        wechatPay.eventChannel = eventChannel;
        
        [wechatPay pay:call.arguments];
        
        result(nil);
    }else if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

@end


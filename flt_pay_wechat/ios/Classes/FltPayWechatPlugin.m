#import "FltPayWechatPlugin.h"

@interface FltPayWechatPlugin()
@property(readwrite, nonatomic) FlutterMethodChannel* channel;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger>* messenger;
@end

@implementation FltPayWechatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"flt_pay_wechat"
              binaryMessenger:[registrar messenger]];
    FltPayWechatPlugin* instance = [[FltPayWechatPlugin alloc] initWithRegistrar:registrar channel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar channel:(FlutterMethodChannel *)channel {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _messenger = [registrar messenger];
    _channel = channel;
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
        result(nil);
    }else if ([@"weChatInit" isEqualToString:call.method]) {
        NSLog(@"此版本没有微信支付(iOS)");
        result([FlutterError errorWithCode:@"UNAVAILABLE"
        message:@"wechat pay unavailable"
        details:@"此版本没有微信支付(iOS)"]);
    }else if ([@"weChatPay" isEqualToString:call.method]) {
        NSLog(@"此版本没有微信支付(iOS)");
        result([FlutterError errorWithCode:@"UNAVAILABLE"
        message:@"wechat pay unavailable"
        details:@"此版本没有微信支付(iOS)"]);
    }else if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

@end


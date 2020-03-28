#import "FltPayAliPlugin.h"


@interface FltPayAliPlugin ()
@property(copy, nonatomic) NSString *scheme;
@property(readwrite, nonatomic) FlutterMethodChannel* channel;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger>* messenger;
@end

@implementation FltPayAliPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"flt_pay_ali"
              binaryMessenger:[registrar messenger]];
    FltPayAliPlugin* instance = [[FltPayAliPlugin alloc] initWithRegistrar:registrar channel:channel];
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
        result(FlutterMethodNotImplemented);
    }else if ([@"aliInit" isEqualToString:call.method]) {
        NSLog(@"此版本不支持支付宝支付(iOS)");
        result([FlutterError errorWithCode:@"UNAVAILABLE"
        message:@"ali pay unavailable"
        details:@"此版本没有支付宝支付(iOS)"]);
    }else if ([@"aliPay" isEqualToString:call.method]) {
        NSLog(@"此版本不支持支付宝支付(iOS)");
        result([FlutterError errorWithCode:@"UNAVAILABLE"
        message:@"ali pay unavailable"
        details:@"此版本没有支付宝支付(iOS)"]);
    }else if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

@end

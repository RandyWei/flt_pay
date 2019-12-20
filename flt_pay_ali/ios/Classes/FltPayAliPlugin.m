#import "FltPayAliPlugin.h"

#import "FltAliPay.h"

@interface FltPayAliPlugin ()
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger>* messenger;
@end

@implementation FltPayAliPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"flt_pay_ali"
              binaryMessenger:[registrar messenger]];
    FltPayAliPlugin* instance = [[FltPayAliPlugin alloc] initWithRegistrar:registrar];
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
        result(FlutterMethodNotImplemented);
    }else if ([@"alipay" isEqualToString:call.method]) {
        FltAliPay *aliPay = [FltAliPay shareInstance];
        
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"flt_pay_ali/pay" binaryMessenger:_messenger];
        [eventChannel setStreamHandler:aliPay];
        aliPay.eventChannel = eventChannel;
        
        [aliPay pay:call.arguments];
        
        result(FlutterMethodNotImplemented);
    }else if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

@end

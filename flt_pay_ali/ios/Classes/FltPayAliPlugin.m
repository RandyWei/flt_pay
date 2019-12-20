#import "FltPayAliPlugin.h"

#import <AlipaySDK/AlipaySDK.h>

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
        _scheme = [NSString stringWithFormat:@"%@", call.arguments[@"scheme"]];
        result(nil);
    }else if ([@"aliPay" isEqualToString:call.method]) {
        NSString *payInfo = [NSString stringWithFormat:@"%@", call.arguments[@"payInfo"]];
        [self pay:payInfo];
        result(nil);
    }else if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            [self payResult:resultDic];
        }];
    }
    return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            [self payResult:resultDic];
        }];
    }
    return YES;
}

- (void)pay:(NSString *)payInfo {
    // 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:payInfo fromScheme:_scheme callback:^(NSDictionary *resultDic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self payResult:resultDic];
        });
    }];
}

- (void)payResult:(NSDictionary *)resultDic {
    NSString *result = [NSString stringWithFormat:@"%@", resultDic[@"resultStatus"]];
    if ([result isEqualToString:@"9000"]) {
        // 订单支付成功
        [self->_channel invokeMethod:@"aliPayResult" arguments:@"Success"];
    }else if ([result isEqualToString:@"6001"]) {
        // 用户中途取消
        [self->_channel invokeMethod:@"aliPayResult" arguments:@"Cancel"];
    }else {
        // 8000    正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
        // 4000    订单支付失败
        // 5000    重复请求
        // 6002    网络连接出错
        // 6004    支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
        // 其它    其它支付错误
        [self->_channel invokeMethod:@"aliPayResult" arguments:@"Fail"];
    }
}

@end

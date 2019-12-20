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
        NSString *appid = [NSString stringWithFormat:@"%@", call.arguments[@"appid"]];
        NSString *link = [NSString stringWithFormat:@"%@", call.arguments[@"scheme"]];
        [WXApi registerApp:appid universalLink:link];
        result(nil);
    }else if ([@"weChatPay" isEqualToString:call.method]) {
        [self pay:call.arguments];
        result(nil);
    }else if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)pay:(NSDictionary *)info {
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = [NSString stringWithFormat:@"%@", info[@"partnerId"]]; // 商家id
    request.prepayId = [NSString stringWithFormat:@"%@", info[@"prepayId"]]; // 预支付订单
    request.package = [NSString stringWithFormat:@"%@", info[@"package"]]; // 商家根据财付通文档填写的数据和签名
    request.nonceStr = [NSString stringWithFormat:@"%@", info[@"nonceStr"]]; // 随机串，防重发
    request.timeStamp = (UInt32)[info[@"timeStamp"] integerValue]; // 时间戳，防重发
    request.sign = [NSString stringWithFormat:@"%@", info[@"sign"]]; // 商家根据微信开放平台文档对数据做的签名

    [WXApi sendReq:request completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                [self->_channel invokeMethod:@"weChatPayResult" arguments:@"Fail"];
            }
        });
    }];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case WXSuccess:
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                [self->_channel invokeMethod:@"weChatPayResult" arguments:@"Success"];
                break;
            case WXErrCodeUserCancel:
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                [self->_channel invokeMethod:@"weChatPayResult" arguments:@"Cancel"];
                break;
            default:
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode, resp.errStr);
                [self->_channel invokeMethod:@"weChatPayResult" arguments:@"Fail"];
                break;
        }
    }else {
//        [self->_channel invokeMethod:@"weChatPayResult" arguments:@"Fail"];
    }
}

- (void)onReq:(BaseReq *)req {

}

@end


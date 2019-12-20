//
//  FltWechatPay.m
//  flt_pay_wechat
//
//  Created by Apple on 2019/12/2.
//

#import "FltWechatPay.h"

@implementation FltWechatPay

+ (instancetype)shareInstance {
    static FltWechatPay *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (BOOL)registerApp:(NSString *)appid universalLink:(nonnull NSString *)universalLink {
    return [WXApi registerApp:appid universalLink:universalLink];
}

- (void)pay:(id)json {
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        [self.eventChannel setStreamHandler:nil];
        self->_eventSink(@"false");
        return;
    }
    
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = [NSString stringWithFormat:@"%@", info[@"partnerId"]]; // 商家id
    request.prepayId = [NSString stringWithFormat:@"%@", info[@"prepayId"]]; // 预支付订单
    request.package = [NSString stringWithFormat:@"%@", info[@"package"]]; // 商家根据财付通文档填写的数据和签名
    request.nonceStr = [NSString stringWithFormat:@"%@", info[@"nonceStr"]]; // 随机串，防重发
    request.timeStamp = (UInt32)[info[@"timeStamp"] integerValue]; // 时间戳，防重发
    request.sign = [NSString stringWithFormat:@"%@", info[@"sign"]]; // 商家根据微信开放平台文档对数据做的签名

    [WXApi sendReq:request completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.eventChannel setStreamHandler:nil];
            self->_eventSink(success ? @"true" : @"false");
        });
    }];
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    _eventSink = events;
    return nil;
}

@end

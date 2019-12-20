//
//  FltAliPay.m
//  flt_pay_ali
//
//  Created by Apple on 2019/12/3.
//

#import "FltAliPay.h"

#import "APRSASigner.h"
#import "FltAliOrderInfo.h"

@implementation FltAliPay

+ (instancetype)shareInstance {
    static FltAliPay *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
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
    
    // 将商品信息赋予AlixPayOrder的成员变量
    FltAliOrderInfo *order = [FltAliOrderInfo new];
    order.app_id = info[@"app_id"];
    order.method = info[@"method"]; // 支付接口名称
    order.charset = info[@"charset"]; // 参数编码格式 推荐 utf-8
    
    // 当前时间点
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    
    order.version = info[@"version"]; // 支付版本
    order.sign_type = info[@"sign_type"]; // 根据商户设置的私钥来决定 RSA RSA2
    
    // 商品数据
    order.biz_content = [FltAliBizContent new];
    order.biz_content.body = info[@"body"]; // 描述
    order.biz_content.subject = info[@"subject"]; // 标题
    order.biz_content.out_trade_no = info[@"no"]; // 订单id
    order.biz_content.timeout_express = info[@"timeout"]; // 超时时间设置
    order.biz_content.total_amount = info[@"amount"]; // 价格
    
    // 将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderInfo = %@", orderInfo);
    
    // 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    // 需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    APRSASigner *signer = [[APRSASigner alloc] initWithPrivateKey:info[@"privateKey"]];
    NSString *signedString = [signer signString:orderInfo withRSA2:[info[@"private"] isEqualToString:@"RSA2"]];
    
    // 应用注册scheme,在AliSDKDemo-Info.plist定义URL types
    NSString *appScheme = info[@"appScheme"];
    
    // 将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@", orderInfoEncoded, signedString];
    
    // 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.eventChannel setStreamHandler:nil];
            
            if (error) {
                self->_eventSink(@"error");
            }else {
                self->_eventSink(jsonString);
            }
        });
    }];
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return nil;
}

@end

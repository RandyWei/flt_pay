//
//  FltAliPay.m
//  flt_pay_ali
//
//  Created by Apple on 2019/12/3.
//

#import "FltAliPay.h"

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

- (void)pay:(NSString *)json fromScheme:(NSString *)appScheme {
    // 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:json fromScheme:appScheme callback:^(NSDictionary *resultDic) {
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

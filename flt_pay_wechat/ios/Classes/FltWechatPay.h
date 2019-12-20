//
//  FltWechatPay.h
//  flt_pay_wechat
//
//  Created by Apple on 2019/12/2.
//

#import <Foundation/Foundation.h>

#import <Flutter/Flutter.h>
#import "WXApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface FltWechatPay : NSObject <FlutterStreamHandler>

@property(nonatomic) FlutterEventChannel* eventChannel;
@property(nonatomic) FlutterEventSink eventSink;

+ (instancetype)shareInstance;
- (BOOL)registerApp:(NSString *)appid universalLink:(NSString *)universalLink;
- (void)pay:(id)json;

@end

NS_ASSUME_NONNULL_END

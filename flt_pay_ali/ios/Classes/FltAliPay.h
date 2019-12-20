//
//  FltAliPay.h
//  flt_pay_ali
//
//  Created by Apple on 2019/12/3.
//

#import <Foundation/Foundation.h>

#import <Flutter/Flutter.h>
#import <AlipaySDK/AlipaySDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface FltAliPay : NSObject <FlutterStreamHandler>

@property(nonatomic) FlutterEventChannel* eventChannel;
@property(nonatomic) FlutterEventSink eventSink;

+ (instancetype)shareInstance;
- (void)pay:(id)json;

@end

NS_ASSUME_NONNULL_END

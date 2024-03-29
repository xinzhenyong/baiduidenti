
//
//  RNBdidentifi.m
//  dashixiong
//
//  Created by linjinsheng on 2019/4/29.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNBdidentifi.h"
#import "BankPhotoPicker.h"
#import <AipOcrSdk/AipOcrSdk.h>
NSString *const kBankInfoEventName = @"BankInfoEventName";

@interface RNBdidentifi ()
{
    RCTPromiseResolveBlock _resolveBlock;
    RCTPromiseRejectBlock _rejectBlock;
}
@property(strong,nonatomic)BankPhotoPicker *bankPhotoPicker;
@end

@implementation RNBdidentifi

RCT_EXPORT_MODULE(BankPhoto);

+ (id)allocWithZone:(struct _NSZone *)zone {
    static RNBdidentifi *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter removeObserver:self];
        [defaultCenter addObserver:self
                          selector:@selector(sendBankPhotoEvent:)
                              name:@"sendBankPhotoEventNotification"
                            object:nil];
    }
    return self;
}

#pragma mark --销毁通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendBankPhotoEventNotification" object:nil];
}

// 接收通知的方法，接收到通知后发送事件到RN端。RN端接收到事件后可以进行相应的逻辑处理或界面跳转
- (void)sendBankPhotoEvent:(NSNotification *)noti {
    NSDictionary *infoDic = noti.userInfo;
    NSLog(@"发给RN的infoDic字符串为%@",infoDic);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString*jsonString=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (jsonString) {
        _resolveBlock(jsonString);
    }
    else{
        NSLog(@"发给RN的infoDic字符串为%@",noti);
//        _rejectBlock(noti);
    }
//    [self sendEventWithName:kBankInfoEventName body:infoDic];
}

// 重写方法，定义支持的事件集合
- (NSArray<NSString *> *)supportedEvents {
    return @[kBankInfoEventName];
}
//注册
RCT_EXPORT_METHOD(regist:(NSString*)accessKey
                  SecretKey:(NSString*)secretKey
                  ){
    NSLog(@"%@;%@",accessKey,secretKey);
    [[AipOcrService shardService] authWithAK:accessKey andSK:secretKey];
}
// 接收传过来
RCT_REMAP_METHOD(photo, resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)reject){
    _resolveBlock=resolver;
    _rejectBlock=reject;
    UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (root.presentedViewController != nil) {
        root = root.presentedViewController;
    }
    [[self _bankPhotoPicker:root] getBankNumOperation];
}

-(BankPhotoPicker*)_bankPhotoPicker:(UIViewController*)vc{
    if(self.bankPhotoPicker == nil){
        self.bankPhotoPicker = [[BankPhotoPicker alloc]initWithViewController:vc];
    }
    return self.bankPhotoPicker;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


@end

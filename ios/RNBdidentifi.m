
//
//  RNBdidentifi.m
//  dashixiong
//
//  Created by linjinsheng on 2019/4/29.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNBdidentifi.h"
#import "BankPhotoPicker.h"

NSString *const kBankInfoEventName = @"BankInfoEventName";

@interface RNBdidentifi ()
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
    [self sendEventWithName:kBankInfoEventName body:infoDic];
}

// 重写方法，定义支持的事件集合
- (NSArray<NSString *> *)supportedEvents {
    return @[kBankInfoEventName];
}

// 接收传过来
RCT_EXPORT_METHOD(bankNumOperation){
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

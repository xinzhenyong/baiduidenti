//
//  BankPhotoViewController.m
//  dashixiong
//
//  Created by linjinsheng on 2019/4/29.
//  Copyright © 2019 Facebook. All rights reserved.
//

//    #error 【必须！】请在 ai.baidu.com中新建App, 绑定BundleId后，在此填写授权信息
//    #error 【必须！】上传至AppStore前，请使用lipo移除AipBase.framework、AipOcrSdk.framework的模拟器架构，参考FAQ：ai.baidu.com/docs#/OCR-iOS-SDK/top
//     授权方法1：在此处填写App的Api Key/Secret Key

//    API Key   TwWXBRMjOphxP0axV6BGjgV8
//    Secret Key   3Kjmcih1wlF7INGgY6MG1s4M1uuy7Nyo


#import "BankPhotoPicker.h"
#import <objc/runtime.h>
#import <AipOcrSdk/AipOcrSdk.h>
#import "ShowBankCardView.h"

@interface BankPhotoPicker ()<UIAlertViewDelegate>

@end

@implementation BankPhotoPicker{
  // 默认的识别成功的回调
  void (^_successHandler)(id);
  // 默认的识别失败的回调
  void (^_failHandler)(NSError *);
}


-(instancetype)initWithViewController:(UIViewController *)vc{
  self=[super init];
  self.viewController=vc;
  return self;
}

- (void)getBankNumOperation
{
  [[AipOcrService shardService] authWithAK:@"TwWXBRMjOphxP0axV6BGjgV8" andSK:@"3Kjmcih1wlF7INGgY6MG1s4M1uuy7Nyo"];
  NSLog(@"获取银行卡号");
  [self bankCardOCROnline];
  
//  [self configCallback];
}


- (void)bankCardOCROnline{
  
  UIViewController * AipCaptureVC =[AipCaptureCardVC ViewControllerWithCardType:CardTypeBankCard
                               andImageHandler:^(UIImage *image) {
                                 [self showCardImage:image];
                                 
                               }];
  
   [self.viewController presentViewController:AipCaptureVC animated:YES completion:nil];
  
//  [self configCallback];
}

- (void)showCardImage:(UIImage *)cardImage
{
    __weak typeof(self) weakSelf = self;
  [[AipOcrService shardService] detectBankCardFromImage:cardImage successHandler:^(id result) {
    
    NSString *card = result[@"result"][@"bank_card_number"];
    card = [card stringByReplacingOccurrencesOfString:@" " withString:@""];
    __block NSString *bankNum = card;
    __block NSString *bankName = result[@"result"][@"bank_name"];
    NSLog(@"默认识别成功的card为%@", card);
    NSLog(@"默认识别成功的bankName为%@", bankName);
    
    //发送银行卡卡号信息通知
//      [[NSNotificationCenter defaultCenter] postNotificationName:@"sendBankPhotoEventNotification" object:nil userInfo:@{@"BankCardNumber":bankNum,@"BankName":bankName,@"BankCardType":@""}];
    
    [[AipOcrService shardService] detectTextAccurateFromImage:cardImage withOptions:nil successHandler:^(id result) {
      
      NSArray *locas = result[@"words_result"];
      
      for (NSDictionary *d in locas)
      {
        NSDictionary *locaD = d[@"location"];
          if([((NSString*)d[@"words"]) hasSuffix:@"银行"]&&[bankName isEqualToString:@""]  ){
              bankName=d[@"words"];
          }
        NSLog(@"locaD%@:%@",d[@"words"],locaD);
          if([self deptNumInputShouldNumber:d[@"words"]]&&((NSString*)d[@"words"]).length>8){
               bankNum=card.length>((NSString*)d[@"words"]).length?card:d[@"words"];
                  CGFloat x = [locaD[@"left"] floatValue];
                  CGFloat y = [locaD[@"top"] floatValue];
                  CGFloat width = [locaD[@"width"] floatValue];
                  CGFloat height = [locaD[@"height"] floatValue];
              
                  if (_successHandler != nil)
                  {
                      _successHandler(result);
                  }
                  
                  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     
                      //发送银行卡卡号信息通知
                      [[NSNotificationCenter defaultCenter] postNotificationName:@"sendBankPhotoEventNotification" object:nil userInfo:@{@"BankCardNumber":bankNum,@"BankName":bankName,@"BankCardType":@""}];
                      
                      UIViewController *topRootViewController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
                      
                      // 在这里加一个这个样式的循环
                      while (topRootViewController.presentedViewController)
                      {
                          // 这里固定写法
                          topRootViewController = topRootViewController.presentedViewController;
                      }
                      
                      [topRootViewController dismissViewControllerAnimated:YES completion:^{
                          NSLog(@"bankPhotoPicker退出");
                      }];
                  }];
                  
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [ShowBankCardView showBankCardWithBankCard:bankNum bankCardImage:[self imageByCroppingWithImage:cardImage cropRect:CGRectMake(x, y, width, height)] btnEventHandler:nil];
                      
                  });
              
          }
        
      }
      
    } failHandler:^(NSError *err){
        NSLog(@"err:%@",err.domain);
    }];
    
  } failHandler:_failHandler];
}

//剪裁图片
- (UIImage*)imageByCroppingWithImage:(UIImage *)myImage cropRect:(CGRect)cropRect
{
  CGRect rect = cropRect;
  rect.origin.x = myImage.scale * rect.origin.x - 10;
  rect.origin.y = myImage.scale * rect.origin.y - 15;
  rect.size.width = myImage.scale * rect.size.width + 20;
  rect.size.height = myImage.scale * rect.size.height + 30;
  
  CGImageRef imageRef = myImage.CGImage;
  CGImageRef imagePartRef=CGImageCreateWithImageInRect(imageRef,rect);
  UIImage * cropImage=[UIImage imageWithCGImage:imagePartRef];
  CGImageRelease(imagePartRef);
  
  return cropImage;
}


- (void)configCallback {
  __weak typeof(self) weakSelf = self;
  
  // 这是默认的识别成功的回调
  _successHandler = ^(id result){
    
    NSLog(@"默认的识别成功的回调为%@", result);
    NSLog(@"默认的识别成功的回调log_id为%@", result[@"log_id"]);
    NSLog(@"默认的识别成功的回调result为%@", result[@"result"]);
    NSLog(@"默认的识别成功的回调bank_card_number为%@", result[@"result"][@"bank_card_number"]);
    NSLog(@"默认的识别成功的回调bank_name为%@", result[@"result"][@"bank_name"]);
  };
  
  _failHandler = ^(NSError *error){
    NSLog(@"%@", error);
    NSString *msg = [NSString stringWithFormat:@"%li:%@", (long)[error code], [error localizedDescription]];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      [[[UIAlertView alloc] initWithTitle:@"识别失败" message:msg delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
  };
}


-(BOOL)shouldAutorotate{
  return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  UIViewController *topRootViewController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
  
  NSLog(@"按了确认键以后");
  
  // 在这里加一个这个样式的循环
  while (topRootViewController.presentedViewController)
  {
    // 这里固定写法
    topRootViewController = topRootViewController.presentedViewController;
  }
  
  [topRootViewController dismissViewControllerAnimated:YES completion:nil];
}

//工具方法，判断是否是数字
- (BOOL) deptNumInputShouldNumber:(NSString *)str
{
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}
@end






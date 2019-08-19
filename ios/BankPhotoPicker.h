//
//  BankPhotoViewController.h
//  dashixiong
//
//  Created by linjinsheng on 2019/4/29.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BankPhotoPicker : NSObject

-(instancetype)initWithViewController:(UIViewController *)vc;
@property(nonatomic,strong)UIViewController *viewController;

- (void)getBankNumOperation;

@end

NS_ASSUME_NONNULL_END

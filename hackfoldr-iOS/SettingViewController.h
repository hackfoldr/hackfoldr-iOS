//
//  SettingViewController.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2017/11/2.
//  Copyright © 2017年 org.g0v. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <XLForm/XLForm.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingViewController : XLFormViewController

@property (nonatomic, copy, nullable) void (^updateHackfoldrPage)(NSString *pageKey, NSError * _Nullable error);

@end

NS_ASSUME_NONNULL_END

//
//  QRCodeViewController.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2017/11/22.
//  Copyright © 2017年 org.g0v. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeViewController : UIViewController

+ (instancetype)viewController;

@property (copy) NSString *qrCodeString;

@property (copy) void (^foundedResult)(NSString *result);

@end

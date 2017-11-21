//
//  QRCodeViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2017/11/22.
//  Copyright © 2017年 org.g0v. All rights reserved.
//

#import "QRCodeViewController.h"

@interface QRCodeViewController ()

@end

@implementation QRCodeViewController

+ (instancetype)viewController {
    return [[UIStoryboard storyboardWithName:@"QRCode" bundle:nil] instantiateViewControllerWithIdentifier:@"QRCodeViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

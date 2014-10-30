//
//  SettingViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/10/11.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateHackfoldrPage:(id)sender {
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

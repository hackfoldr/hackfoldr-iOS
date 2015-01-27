//
//  ListFieldViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/8/31.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "ListFieldViewController.h"

#import "HackfoldrPage.h"

@implementation ListFieldViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.settingButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    self.settingButton.frame = CGRectMake(0, 0, 20, 20);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self.tableView.dataSource isKindOfClass:[HackfoldrPage class]]) {
        self.title = ((HackfoldrPage *)self.tableView.dataSource).pageTitle;
    }

    if (self.navigationController) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.settingButton];
    }
}

@end

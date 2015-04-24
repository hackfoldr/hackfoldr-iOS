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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.settingButton];
    // Hide back button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.tableView.dataSource && [self.tableView.dataSource isKindOfClass:[HackfoldrPage class]]) {
        self.title = ((HackfoldrPage *)self.tableView.dataSource).pageTitle;
    }
}

@end

//
//  ListFieldViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/8/31.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "ListFieldViewController.h"

#import "HackfoldrPage.h"

@interface ListFieldViewController ()

@end

@implementation ListFieldViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self.tableView.dataSource isKindOfClass:[HackfoldrPage class]]) {
        self.title = ((HackfoldrPage *)self.tableView.dataSource).pageTitle;
    }
}

@end

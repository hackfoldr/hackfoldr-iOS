//
//  ListViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/8/31.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "ListViewController.h"

#import "HackfolerClient.h"
#import "HackfolerPage.h"

@interface ListViewController () <UITabBarControllerDelegate>
@property (nonatomic, strong) IBOutlet UIButton *settingButton;
@end

@implementation ListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.tableView.delegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HackfolerField *field = [HackfolerClient sharedClient].lastPage.cells[indexPath.row];
    NSString *urlString = field.urlString;
    NSLog(@"url: %@", urlString);

    if (urlString && urlString.length == 0) {
        return;
    }
}

- (IBAction)settingAction:(id)sender
{
    NSLog(@"setting button clicked");
}

@end

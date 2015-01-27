//
//  MainViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/21.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "MainViewController.h"

// Model & Client
#import "HackfoldrClient.h"
#import "HackfoldrPage.h"
// ViewController
#import "TOWebViewController+HackfoldrField.h"
#import "ListFieldViewController.h"
#import "SettingViewController.h"

static NSString *kDefaultHackfoldrPage = @"Default Hackfolder Page";

@interface MainViewController () <UITableViewDelegate>
@property (nonatomic, strong) TOWebViewController *webViewController;
@property (nonatomic, strong) ListFieldViewController *listViewController;
@property (nonatomic, strong) HackfoldrField *currentField;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleName"];

    self.listViewController = [[ListFieldViewController alloc] init];
    self.listViewController.tableView = [[UITableView alloc] initWithFrame:self.listViewController.tableView.frame
                                                                     style:UITableViewStyleGrouped];
    self.listViewController.tableView.delegate = self;
    [self.listViewController.settingButton addTarget:self
                                              action:@selector(settingAction:)
                                    forControlEvents:UIControlEventTouchUpInside];

    self.webViewController = [[TOWebViewController alloc] init];
    self.webViewController.showPageTitles = NO;

    UIImage *backgroundImage = [[UIImage imageNamed:@"hackfoldr-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.tintColor = [UIColor colorWithRed:0.888 green:0.953 blue:0.826 alpha:1.000];
    backgroundImageView.backgroundColor = [UIColor clearColor];
    CGFloat imageSize = 176.f;
    backgroundImageView.frame = CGRectMake(CGRectGetWidth(self.view.frame)/2.f - imageSize/2.f,
                                           CGRectGetHeight(self.view.frame)/2.f - imageSize/2.f,
                                           imageSize,
                                           imageSize);

    if (backgroundImageView) {
        [self.view addSubview:backgroundImageView];
    }

    self.view.backgroundColor = [UIColor colorWithRed:0.490 green:0.781 blue:0.225 alpha:1.000];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSString *)hackfoldrPageKey
{
    NSString *pageKey = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultHackfoldrPage];

    if (!pageKey || pageKey.length == 0) {
        NSString *defaultPage = @"hackfoldr-iOS";
#if DEBUG
        defaultPage = @"kuansim";
#endif

        [[NSUserDefaults standardUserDefaults] setObject:defaultPage forKey:kDefaultHackfoldrPage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        pageKey = defaultPage;
    }

    return pageKey;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[[HackfoldrClient sharedClient] pagaDataAtPath:self.hackfoldrPageKey] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"error:%@", task.error);
        }

        NSLog(@"%@", task.result);
        self.listViewController.tableView.dataSource = [HackfoldrClient sharedClient].lastPage;

        [self.listViewController.tableView reloadData];
        if (!self.currentField) {
            [self showListViewController];
        }
        return nil;
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.listViewController.tableView) {
        HackfoldrField *field = [HackfoldrClient sharedClient].lastPage.cells[indexPath.row];
        NSString *urlString = field.urlString;
        NSLog(@"url: %@", urlString);

        if (urlString && urlString.length == 0) {
            return;
        }

        [self dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:self.webViewController animated:YES completion:^{
                [self.webViewController loadWithField:field];
                self.currentField = field;
            }];
        }];
    }
}

- (void)settingAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIViewController *settingViewController = [[SettingViewController alloc] init];
        UINavigationController *navigationForSetting = [[UINavigationController alloc] initWithRootViewController:settingViewController];
        [self presentViewController:navigationForSetting animated:YES completion:nil];
    }];
}

#pragma mark - Actions

- (void)showListViewController {
    UINavigationController *navigationControllerForListViewController =
    [[UINavigationController alloc] initWithRootViewController:self.listViewController];
    [self presentViewController:navigationControllerForListViewController animated:YES completion:nil];
}

@end

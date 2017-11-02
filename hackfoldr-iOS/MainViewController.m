//
//  MainViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/21.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "MainViewController.h"

#import <CoreSpotlight/CoreSpotlight.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

#import "AppDelegate.h"
// Model & Client
#import "HackfoldrClient.h"
#import "HackfoldrPage.h"
// Category
#import "HackfoldrClient+Store.h"
#import "NSUserDefaults+DefaultHackfoldrPage.h"
#import "UIColor+Hackfoldr.h"
// ViewController
#import <RATreeView/RATreeView.h>
#import "ListFieldViewController.h"

@interface MainViewController () <UITableViewDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) ListFieldViewController *listViewController;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleName"];

    UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    CGFloat iconSize = 24;
    reloadButton.frame = CGRectMake(0, 0, iconSize, iconSize);
    UIImage *reloadImage =  [[FAKFontAwesome refreshIconWithSize:iconSize] imageWithSize:reloadButton.frame.size];
    [reloadButton setImage:reloadImage forState:UIControlStateNormal];
    [reloadButton addTarget:self
                     action:@selector(reloadAction:)
           forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reloadButton];

    self.listViewController = [ListFieldViewController viewController];

    UIImage *backgroundImage = [[UIImage imageNamed:@"hackfoldr-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.backgroundImageView.tintColor = [UIColor colorWithRed:0.888 green:0.953 blue:0.826 alpha:1.000];
    self.backgroundImageView.backgroundColor = [UIColor clearColor];
    [self updateBackgroundImageWithSize:self.view.frame.size];

    if (self.backgroundImageView) {
        [self.view addSubview:self.backgroundImageView];
    }

    self.view.backgroundColor = [UIColor hackfoldrGreenColor];

    [self mainNavigationController].delegate = self;

    [CSSearchableIndex.defaultSearchableIndex deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"deleteAllSearchableItems %@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setter & Getter

- (UINavigationController *)mainNavigationController
{
    return (UINavigationController *)((AppDelegate *)[UIApplication sharedApplication].delegate).viewController;
}

- (void)updateBackgroundImageWithSize:(CGSize)size
{
    CGFloat imageSize = 176.f;
    self.backgroundImageView.frame = CGRectMake(size.width/2.f - imageSize/2.f,
                                                size.height/2.f - imageSize/2.f,
                                                imageSize,
                                                imageSize);
}

- (NSString *)hackfoldrPageKey
{
    NSString *pageKey = [[NSUserDefaults standardUserDefaults] stringOfCurrentHackfoldrPage];

    if (!pageKey || pageKey.length == 0) {
        NSString *defaultPage = @"hackfoldr-iOS";

        [[NSUserDefaults standardUserDefaults] setDefaultHackfoldrPage:defaultPage];
        [[NSUserDefaults standardUserDefaults] synchronize];

        pageKey = [[NSUserDefaults standardUserDefaults] stringOfCurrentHackfoldrPage];
    }

    return pageKey;
}

#pragma mark - View Flow

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self reloadAction:self];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self updateBackgroundImageWithSize:size];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

}

#pragma mark - Actions

- (void)showListViewController
{
    // When List view is showed, don't show again
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[self.listViewController class]] && vc == self.listViewController) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }

    [self.navigationController pushViewController:self.listViewController animated:YES];
}

- (void)reloadAction:(id)sender
{
    HackfoldrTaskCompletionSource *completionSource = [[HackfoldrClient sharedClient] hackfoldrPageTaskWithKey:[self hackfoldrPageKey] rediredKey:nil];

    NSString *title = NSLocalizedStringFromTable(@"Error", @"Hackfoldr", @"Error title");
    NSString *cancelButtonTitle = NSLocalizedStringFromTable(@"Cancel", @"Hackfoldr", @"Alert Cancel button");
    NSString *setupTitle = NSLocalizedStringFromTable(@"Setup Key", @"Hackfoldr", @"Alert Setup button");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:setupTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.listViewController showSettingViewController];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if ([HackfoldrClient sharedClient].lastPage) {
            [self showListViewController];
        }
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [completionSource.task continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            [self presentViewController:alert animated:YES completion:nil];
        }
        return nil;
    }];

    [completionSource.task continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        [self showListViewController];

        HackfoldrPage *page = t.result;
        self.listViewController.page = page;
        // Reload tableView
        [self.listViewController reloadPage];
        return nil;
    }];
}

#pragma mark - Public method

- (void)updateHackfoldrPageWithKey:(NSString *)hackfoldrKey
{
    [self.listViewController updateHackfoldrPageWithKey:hackfoldrKey];
}

@end

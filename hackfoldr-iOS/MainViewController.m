//
//  MainViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/21.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "MainViewController.h"

#import "AppDelegate.h"
// Model & Client
#import "CoreData+MagicalRecord.h"
#import "HackfoldrClient.h"
#import "HackfoldrHistory.h"
#import "HackfoldrPage.h"
#import "NSUserDefaults+DefaultHackfoldrPage.h"
// ViewController
#import "ListFieldViewController.h"
#import "QuickDialog.h"
#import "TOWebViewController+HackfoldrField.h"
#import "UIAlertView+AFNetworking.h"

@interface MainViewController () <UITableViewDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) ListFieldViewController *listViewController;
@property (nonatomic, strong) HackfoldrField *currentField;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign) BOOL isSettingUpdating;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleName"];

    UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [reloadButton addTarget:self
                     action:@selector(reloadAction:)
           forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reloadButton];

    self.listViewController = [[ListFieldViewController alloc] init];
    self.listViewController.tableView = [[UITableView alloc] initWithFrame:self.listViewController.tableView.frame
                                                                     style:UITableViewStyleGrouped];
    self.listViewController.tableView.delegate = self;
    [self.listViewController.settingButton addTarget:self
                                              action:@selector(settingAction:)
                                    forControlEvents:UIControlEventTouchUpInside];

    UIImage *backgroundImage = [[UIImage imageNamed:@"hackfoldr-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.backgroundImageView.tintColor = [UIColor colorWithRed:0.888 green:0.953 blue:0.826 alpha:1.000];
    self.backgroundImageView.backgroundColor = [UIColor clearColor];
    [self updateBackgroundImageWithSize:self.view.frame.size];

    if (self.backgroundImageView) {
        [self.view addSubview:self.backgroundImageView];
    }

    self.view.backgroundColor = [UIColor colorWithRed:0.490 green:0.781 blue:0.225 alpha:1.000];

    [self mainNavigationController].delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setter & Getter

- (NSString *)hackfoldrPageKey
{
    NSString *pageKey = [[NSUserDefaults standardUserDefaults] stringOfCurrentHackfoldrPage];

    if (!pageKey || pageKey.length == 0) {
        NSString *defaultPage = @"hackfoldr-iOS";
#if DEBUG
        defaultPage = @"welcome-to-hackfoldr";
#endif

        [[NSUserDefaults standardUserDefaults] setDefaultHackfoldrPage:defaultPage];
        [[NSUserDefaults standardUserDefaults] synchronize];

        pageKey = [[NSUserDefaults standardUserDefaults] stringOfCurrentHackfoldrPage];
    }

    return pageKey;
}

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

#pragma mark - View Flow

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.isSettingUpdating == NO) {
        [self reloadAction:self];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self updateBackgroundImageWithSize:size];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.listViewController.tableView) {
        HackfoldrField *sectionOfField = [HackfoldrClient sharedClient].lastPage.cells[indexPath.section];
        HackfoldrField *rowOfField = sectionOfField.subFields[indexPath.row];
        NSString *urlString = rowOfField.urlString;
        NSLog(@"url: %@", urlString);

        if (!urlString || urlString.length == 0) {
            // TODO: show nil message
            return;
        }

        TOWebViewController *webViewController = [[TOWebViewController alloc] init];
        webViewController.showPageTitles = YES;
        [self dismissViewControllerAnimated:YES completion:^{
            [webViewController loadWithField:rowOfField];
            self.currentField = rowOfField;

            [[self mainNavigationController] pushViewController:webViewController animated:YES];
        }];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self == viewController) {
        self.currentField = nil;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView clickedAt:%ld", buttonIndex);
    if (buttonIndex == 1) {
        [self showSettingViewController];
        return;
    }

    if ([HackfoldrClient sharedClient].lastPage) {
        [self showListViewController];
    }
}

#pragma mark - Actions

- (void)showListViewController {
    UINavigationController *navigationControllerForListViewController =
    [[UINavigationController alloc] initWithRootViewController:self.listViewController];
    [self presentViewController:navigationControllerForListViewController animated:YES completion:nil];
}

- (void)showSettingViewController
{
    QRootElement *settingRoot = [[QRootElement alloc] init];
    settingRoot.title = NSLocalizedStringFromTable(@"Change Hackfoldr Page", @"Hackfoldr", @"Title of SettingView");
    settingRoot.grouped = YES;

    QuickDialogController *dialogController = [QuickDialogController controllerForRoot:settingRoot];
    UINavigationController *navigationForSetting = [[UINavigationController alloc] initWithRootViewController:dialogController];

    QSection *inputSection = [[QSection alloc] init];
    inputSection.footer = @"You can input new hackfoldr page key and select Change Key to change it.";

    QLabelElement *currentHackpageKey = [[QLabelElement alloc] init];
    currentHackpageKey.title = @"Current key";
    currentHackpageKey.value = [[NSUserDefaults standardUserDefaults] stringOfCurrentHackfoldrPage];
    [inputSection addElement:currentHackpageKey];

    QEntryElement *inputElement = [[QEntryElement alloc] init];
    inputElement.placeholder = @"Hackfoldr key or URL";
    [inputSection addElement:inputElement];

    QButtonElement *sendButtonElement = [[QButtonElement alloc] init];
    sendButtonElement.title = NSLocalizedStringFromTable(@"Change Key", @"Hackfoldr", @"update hackfoldr button text");
    // Change page button clicked
    sendButtonElement.onSelected = ^(void) {

        NSString *newHackfoldrPage = inputElement.textValue;

        // Find hackfoldr page key, if prefix is http or https
        if ([newHackfoldrPage hasPrefix:@"http"]) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*hackfoldr.org/(.*)/"
                                                                                   options:NSRegularExpressionAllowCommentsAndWhitespace
                                                                                     error:NULL];
            NSTextCheckingResult *match = [regex firstMatchInString:newHackfoldrPage
                                                            options:NSMatchingReportCompletion
                                                              range:NSMakeRange(0, newHackfoldrPage.length)];
            if (match.range.location != NSNotFound) {
                newHackfoldrPage = [newHackfoldrPage substringWithRange:[match rangeAtIndex:1]];
            }
        }

        // Remove white space and new line
        newHackfoldrPage = [newHackfoldrPage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // Use escapes to encoding |newHackfoldrPage|
        newHackfoldrPage = [newHackfoldrPage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if (newHackfoldrPage && newHackfoldrPage.length > 0) {
            self.isSettingUpdating = YES;
            [dialogController loading:YES];

            HackfoldrTaskCompletionSource *completionSource = [self updateHackfoldrPageTaskWithKey:newHackfoldrPage];

            NSString *dismissButtonTitle = NSLocalizedStringFromTable(@"Dismiss", @"Hackfoldr", @"Dismiss button at SettingView");
            [UIAlertView showAlertViewForTaskWithErrorOnCompletion:completionSource.connectionTask
                                                          delegate:self
                                                 cancelButtonTitle:dismissButtonTitle
                                                 otherButtonTitles:nil];

            [[completionSource.task continueWithBlock:^id(BFTask *task) {
                self.isSettingUpdating = NO;
                [dialogController loading:NO];
                return task;
            }] continueWithSuccessBlock:^id(BFTask *task) {
                NSLog(@"change hackfoldr page: %@", newHackfoldrPage);
                [[NSUserDefaults standardUserDefaults] setCurrentHackfoldrPage:newHackfoldrPage];
                [navigationForSetting dismissViewControllerAnimated:YES completion:nil];
                return nil;
            }];
        } else {
            [navigationForSetting dismissViewControllerAnimated:YES completion:nil];
        }
    };
    [inputSection addElement:sendButtonElement];
    [settingRoot addSection:inputSection];

    QSection *historySection = [[QSection alloc] init];
    historySection.title = NSLocalizedStringFromTable(@"History", @"Hackfoldr", @"History section title at SettingView");
    NSArray *histories = [HackfoldrHistory MR_findAllSortedBy:@"refreshDate" ascending:NO];
    [histories enumerateObjectsUsingBlock:^(HackfoldrHistory *history, NSUInteger idx, BOOL *stop) {
        QButtonElement *buttonElement = [[QButtonElement alloc] init];
        buttonElement.title = history.title;
        buttonElement.onSelected = ^() {
            [[NSUserDefaults standardUserDefaults] setCurrentHackfoldrPage:history.hackfoldrKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // hide self
            [navigationForSetting dismissViewControllerAnimated:YES completion:nil];
        };
        [historySection addElement:buttonElement];
    }];
    [settingRoot addSection:historySection];

    QSection *restSection = [[QSection alloc] init];
    restSection.title = NSLocalizedStringFromTable(@"Reset Actions", @"Hackfoldr", @"Reset hackfoldr actions at SettingView");
    QButtonElement *restHackfoldrPageElement = [[QButtonElement alloc] init];
    restHackfoldrPageElement.title = NSLocalizedStringFromTable(@"Default Hackfoldr Page", @"Hackfoldr", @"Reset hackfoldr page");
    restHackfoldrPageElement.onSelected = ^(void) {
        // Set current HackfoldrPage to |DefaultHackfoldrPage|
        NSString *defaultHackfoldrKey = [[NSUserDefaults standardUserDefaults] stringOfDefaultHackfoldrPage];
        [[NSUserDefaults standardUserDefaults] setCurrentHackfoldrPage:defaultHackfoldrKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // hide self
        [navigationForSetting dismissViewControllerAnimated:YES completion:nil];
    };
    [restSection addElement:restHackfoldrPageElement];
    [settingRoot addSection:restSection];

    QSection *infoSection = [[QSection alloc] init];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    infoSection.footer = [NSString stringWithFormat:@"App Version: %@ (%@)", version, build];
    [settingRoot addSection:infoSection];

    [self presentViewController:navigationForSetting animated:YES completion:nil];
}

- (HackfoldrTaskCompletionSource *)updateHackfoldrPageTaskWithKey:(NSString *)hackfoldrKey
{
    HackfoldrTaskCompletionSource *completionSource = nil;

    // check where the data come from, ethercalc or gsheet
    if (hackfoldrKey.length < 40) {
        completionSource = [[HackfoldrClient sharedClient] taskCompletionFromEthercalcWithKey:hackfoldrKey];
    } else {
        completionSource = [[HackfoldrClient sharedClient] taskCompletionFromGoogleSheetWithSheetKey:hackfoldrKey];
    }

    [completionSource.task continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            return task;
        }
        HackfoldrPage *page = task.result;
        NSLog(@"result:%@", page);

        // Save history to core data
        HackfoldrHistory *history = [HackfoldrHistory MR_findFirstByAttribute:@"hackfoldrKey" withValue:hackfoldrKey];
        if (!history) {
            history = [HackfoldrHistory MR_createEntity];
            history.createDate = [NSDate date];
            history.refreshDate = [NSDate date];
            history.hackfoldrKey = hackfoldrKey;
            history.title = page.pageTitle;
        } else {
            history.refreshDate = [NSDate date];
            history.title = page.pageTitle;
        }

        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:nil];

        return nil;
    }];

    // Reload tableView
    [completionSource.task continueWithSuccessBlock:^id(BFTask *task) {
        self.listViewController.tableView.dataSource = [HackfoldrClient sharedClient].lastPage;

        [self.listViewController.tableView reloadData];
        if (!self.currentField) {
            [self showListViewController];
        }
        return nil;
    }];
    return completionSource;
}

- (void)settingAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self showSettingViewController];
    }];
}

- (void)reloadAction:(id)sender
{
    HackfoldrTaskCompletionSource *completionSource = [self updateHackfoldrPageTaskWithKey:self.hackfoldrPageKey];

    NSString *cancelButtonTitle = NSLocalizedStringFromTable(@"Cancel", @"Hackfoldr", @"Alert Cancel button");
    NSString *setupTitle = NSLocalizedStringFromTable(@"Setup Key", @"Hackfoldr", @"Alert Setup button");

    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:completionSource.connectionTask
                                                  delegate:self
                                         cancelButtonTitle:cancelButtonTitle
                                         otherButtonTitles:setupTitle ,nil];
}

@end

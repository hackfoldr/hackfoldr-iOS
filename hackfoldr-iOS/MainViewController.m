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
#import "UIImage+TOWebViewControllerIcons.h"
// ViewController
#import "ListFieldViewController.h"
#import "QuickDialog.h"
#import "TOWebViewController+HackfoldrField.h"
#import "UIAlertView+AFNetworking.h"

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
    reloadButton.frame = CGRectMake(0, 0, 31, 31);
    UIImage *reloadImage = [UIImage TOWebViewControllerIcon_refreshButtonWithAttributes:nil];
    [reloadButton setImage:reloadImage forState:UIControlStateNormal];
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

    [self reloadAction:self];
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
        HackfoldrPage *dataSourcePage = tableView.dataSource;
        HackfoldrField *sectionOfField = dataSourcePage.cells[indexPath.section];
        HackfoldrField *rowOfField = sectionOfField.subFields[indexPath.row];
        NSString *urlString = rowOfField.urlString;
        NSLog(@"url: %@", urlString);

        if (!urlString || urlString.length == 0) {
            // TODO: show nil message
            return;
        }

        TOWebViewController *webViewController = [[TOWebViewController alloc] init];
        webViewController.showPageTitles = YES;
        [webViewController loadWithField:rowOfField];

        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

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

- (void)showListViewController
{
    // When List view is showed, don't show again
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[self.listViewController class]]) {
            [self.navigationController popToViewController:self.listViewController animated:YES];
            return;
        }
    }

    [self.navigationController pushViewController:self.listViewController animated:YES];
}

- (void)showSettingViewController
{
    // When Setting view is showed, don't show again
    for (QuickDialogController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[QuickDialogController class]]) {
            return;
        }
    }

    QRootElement *settingRoot = [[QRootElement alloc] init];
    settingRoot.title = NSLocalizedStringFromTable(@"Setting Hackfoldr Page", @"Hackfoldr", @"Title of SettingView");
    settingRoot.grouped = YES;

    QuickDialogController *dialogController = [QuickDialogController controllerForRoot:settingRoot];

    QSection *inputSection = [[QSection alloc] init];
    inputSection.footer = NSLocalizedStringFromTable(@"You can input new hackfoldr page key and select Change Key to change it.", @"Hackfoldr", @"Change key description at input section in SettingView.");

    QLabelElement *currentHackpageKey = [[QLabelElement alloc] init];
    currentHackpageKey.title = NSLocalizedStringFromTable(@"Current key", @"Hackfoldr", @"Current key title in SettingView.");
    currentHackpageKey.value = [[NSUserDefaults standardUserDefaults] stringOfCurrentHackfoldrPage];
    [inputSection addElement:currentHackpageKey];

    QEntryElement *inputElement = [[QEntryElement alloc] init];
    inputElement.placeholder = NSLocalizedStringFromTable(@"Hackfoldr key or URL", @"Hackfoldr", @"Place holder string for input element in SettingView.");
    [inputSection addElement:inputElement];

    QButtonElement *sendButtonElement = [[QButtonElement alloc] init];
    sendButtonElement.title = NSLocalizedStringFromTable(@"Change Key", @"Hackfoldr", @"Change hackfoldr key button title in SettingView.");
    // Change page button clicked
    sendButtonElement.onSelected = ^(void) {

        BFTaskCompletionSource *cleanKeyCompletionSource = [self validatorHackfoldrKeyForSettingViewWithHackfoldrKey:inputElement.textValue];
        [cleanKeyCompletionSource.task continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                // hide self
                [dialogController popToPreviousRootElement];
                return nil;
            }
            // Update hackfoldr page
            [self updateHackfoldrPageWithDialogController:dialogController key:task.result];

            return nil;;
        }];
    };
    [inputSection addElement:sendButtonElement];
    [settingRoot addSection:inputSection];

    QSection *historySection = [[QSection alloc] init];
    historySection.title = NSLocalizedStringFromTable(@"History", @"Hackfoldr", @"History section title in SettingView");
    NSArray *histories = [HackfoldrHistory MR_findAllSortedBy:@"refreshDate" ascending:NO];
    [histories enumerateObjectsUsingBlock:^(HackfoldrHistory *history, NSUInteger idx, BOOL *stop) {
        QButtonElement *buttonElement = [[QButtonElement alloc] init];
        buttonElement.title = history.title;
        buttonElement.onSelected = ^() {
            // Update hackfoldr page
            [self updateHackfoldrPageWithDialogController:dialogController key:history.hackfoldrKey];
        };
        [historySection addElement:buttonElement];
    }];
    [settingRoot addSection:historySection];

    QSection *restSection = [[QSection alloc] init];
    restSection.title = NSLocalizedStringFromTable(@"Reset Actions", @"Hackfoldr", @"Reset hackfoldr actions in SettingView");
    QButtonElement *restHackfoldrPageElement = [[QButtonElement alloc] init];
    restHackfoldrPageElement.title = NSLocalizedStringFromTable(@"Hackfoldr Help", @"Hackfoldr", @"Reset hackfoldr page button title in SettingView");
    restHackfoldrPageElement.onSelected = ^(void) {
        // Set current HackfoldrPage to |DefaultHackfoldrPage|
        NSString *defaultHackfoldrKey = [[NSUserDefaults standardUserDefaults] stringOfDefaultHackfoldrPage];
        [[NSUserDefaults standardUserDefaults] setCurrentHackfoldrPage:defaultHackfoldrKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // hide self
        [dialogController popToPreviousRootElement];
    };
    [restSection addElement:restHackfoldrPageElement];
    [settingRoot addSection:restSection];

    QSection *infoSection = [[QSection alloc] init];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    infoSection.footer = [NSString stringWithFormat:@"App Version: %@ (%@)", version, build];
    [settingRoot addSection:infoSection];

    if (self.listViewController.navigationController) {
        [self.listViewController.navigationController pushViewController:dialogController animated:YES];
    } else {
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:dialogController];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (BFTaskCompletionSource *)validatorHackfoldrKeyForSettingViewWithHackfoldrKey:(NSString *)newHackfoldrKey
{
    BFTaskCompletionSource *completion = [BFTaskCompletionSource taskCompletionSource];

    // Find hackfoldr page key, if prefix is http or https
    if ([newHackfoldrKey hasPrefix:@"http"]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*hackfoldr.org/(.*)/"
                                                                               options:NSRegularExpressionAllowCommentsAndWhitespace
                                                                                 error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:newHackfoldrKey
                                                        options:NSMatchingReportCompletion
                                                          range:NSMakeRange(0, newHackfoldrKey.length)];
        if (match.range.location != NSNotFound) {
            newHackfoldrKey = [newHackfoldrKey substringWithRange:[match rangeAtIndex:1]];
        }
    }

    // Remove white space and new line
    newHackfoldrKey = [newHackfoldrKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // Use escapes to encoding |newHackfoldrPage|
    newHackfoldrKey = [newHackfoldrKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if (newHackfoldrKey && newHackfoldrKey.length > 0) {
        [completion setResult:newHackfoldrKey];
    } else {
        [completion setError:[NSError errorWithDomain:@"SettingView"
                                                 code:1
                                             userInfo:nil]];
    }

    return completion;
}

- (void)updateHackfoldrPageWithDialogController:(QuickDialogController *)dialogController key:(NSString *)hackfoldrKey
{
    NSString *rediredKey = nil;
    // lookup |rediredKey| from core data
    HackfoldrHistory *history = [HackfoldrHistory MR_findFirstByAttribute:@"hackfoldrKey" withValue:hackfoldrKey];
    if (history && history.rediredKey) {
        rediredKey = history.rediredKey;
    }

    HackfoldrTaskCompletionSource *completionSource = [self updateHackfoldrPageTaskWithKey:hackfoldrKey rediredKey:rediredKey];

    NSString *dismissButtonTitle = NSLocalizedStringFromTable(@"Dismiss", @"Hackfoldr", @"Dismiss button title in SettingView");
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:completionSource.connectionTask
                                                  delegate:self
                                         cancelButtonTitle:dismissButtonTitle
                                         otherButtonTitles:nil];

    [dialogController loading:YES];

    [[completionSource.task continueWithBlock:^id(BFTask *task) {
        [dialogController loading:NO];
        return task;
    }] continueWithSuccessBlock:^id(BFTask *task) {
        NSLog(@"change hackfoldr page to: %@", hackfoldrKey);
        // Just save |hackfoldrKey| to user defaults
        [[NSUserDefaults standardUserDefaults] setCurrentHackfoldrPage:hackfoldrKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return task;
    }];
}

- (HackfoldrTaskCompletionSource *)updateHackfoldrPageTaskWithKey:(NSString *)hackfoldrKey rediredKey:(NSString *)rediredKey
{
    NSString *key = hackfoldrKey;
    if (rediredKey) {
        key = rediredKey;
    }

    HackfoldrTaskCompletionSource *completionSource = [[HackfoldrClient sharedClient] taskCompletionWithKey:key];

    [[completionSource.task continueWithSuccessBlock:^id(BFTask *task) {
        HackfoldrPage *page = task.result;
        NSLog(@"result:%@", page);

        if (page.rediredKey) {
            NSLog(@"redired to:%@", page.rediredKey);
            return [self updateHackfoldrPageTaskWithKey:hackfoldrKey rediredKey:page.rediredKey].task;
        }

        // Save |history| to core data
        HackfoldrHistory *history = [HackfoldrHistory MR_findFirstByAttribute:@"hackfoldrKey" withValue:hackfoldrKey];
        if (!history) {
            history = [HackfoldrHistory MR_createEntity];
            history.createDate = [NSDate date];
            history.refreshDate = [NSDate date];
            history.hackfoldrKey = hackfoldrKey;
            history.title = page.pageTitle;
            if (rediredKey) {
                history.rediredKey = rediredKey;
            }
        } else {
            history.refreshDate = [NSDate date];
            history.title = page.pageTitle;
            if (rediredKey) {
                history.rediredKey = rediredKey;
            }
        }

        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:nil];

        return task;
    }] continueWithSuccessBlock:^id(BFTask *task) {
        HackfoldrPage *page = task.result;
        // Don't reload because this is redired page
        if (page.rediredKey) {
            return nil;
        }

        // Reload tableView
        self.listViewController.tableView.dataSource = page;
        [self.listViewController.tableView reloadData];

        [self showListViewController];
        return nil;
    }];
    return completionSource;
}

- (void)settingAction:(id)sender
{
    [self showSettingViewController];
}

- (void)reloadAction:(id)sender
{
    HackfoldrTaskCompletionSource *completionSource = [self updateHackfoldrPageTaskWithKey:self.hackfoldrPageKey rediredKey:nil];

    NSString *cancelButtonTitle = NSLocalizedStringFromTable(@"Cancel", @"Hackfoldr", @"Alert Cancel button");
    NSString *setupTitle = NSLocalizedStringFromTable(@"Setup Key", @"Hackfoldr", @"Alert Setup button");

    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:completionSource.connectionTask
                                                  delegate:self
                                         cancelButtonTitle:cancelButtonTitle
                                         otherButtonTitles:setupTitle ,nil];
}

@end

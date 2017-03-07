//
//  ListFieldViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/8/31.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "ListFieldViewController.h"

#import <Bolts/Bolts.h>

// Model & Client
#import <MagicalRecord/MagicalRecord.h>
#import "HackfoldrClient.h"
#import "HackfoldrHistory.h"
#import "HackfoldrPage.h"
// Category
#import "NSUserDefaults+DefaultHackfoldrPage.h"
#import "NSURL+Hackfoldr.h"
#import "UIImage+TOWebViewControllerIcons.h"
// ViewController
#import <SafariServices/SafariServices.h>
#import "ListFieldViewController.h"
#import "QuickDialog.h"
#import "TOWebViewController+HackfoldrField.h"
#import "UIAlertView+AFNetworking.h"

@interface ListFieldViewController ()
@property (nonatomic, strong) QuickDialogController *dialogController;
@end

@implementation ListFieldViewController

+ (instancetype)viewController {
    return [[ListFieldViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;

    self.settingButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [self.settingButton addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    int iconSize = 26;
    self.settingButton.frame = CGRectMake(0, 0, iconSize, iconSize);
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
    self.dialogController = dialogController;

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

        BFTask *cleanKeyTask = [self validatorHackfoldrKeyForSettingViewWithHackfoldrKey:inputElement.textValue];
        [cleanKeyTask continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                // hide self
                [dialogController popToPreviousRootElement];
                return nil;
            }
            // Update hackfoldr page
            [[self updateHackfoldrPageWithDialogController:dialogController key:task.result] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                [self.tableView reloadData];
                [self.navigationController popViewControllerAnimated:YES];
                return nil;
            }];

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
            [[self updateHackfoldrPageWithDialogController:dialogController key:history.hackfoldrKey] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                [self.tableView reloadData];
                [self.navigationController popViewControllerAnimated:YES];
                return nil;
            }];
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
        // update hackfoldr page
        [[self updateHackfoldrPageWithDialogController:dialogController key:defaultHackfoldrKey] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
            [self.tableView reloadData];
            [self.navigationController popViewControllerAnimated:YES];
            return nil;
        }];
    };
    [restSection addElement:restHackfoldrPageElement];
    [settingRoot addSection:restSection];

    QSection *infoSection = [[QSection alloc] init];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    infoSection.footer = [NSString stringWithFormat:@"App Version: %@ (%@)", version, build];
    [settingRoot addSection:infoSection];

    if (self.navigationController) {
        [self.navigationController pushViewController:dialogController animated:YES];
    } else {
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:dialogController];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (BFTask *)validatorHackfoldrKeyForSettingViewWithHackfoldrKey:(NSString *)newHackfoldrKey
{
    BFTaskCompletionSource *completion = [BFTaskCompletionSource taskCompletionSource];

    NSString *validatorKey = [NSURL validatorHackfoldrKey:newHackfoldrKey];

    if (validatorKey && validatorKey.length > 0) {
        [completion setResult:validatorKey];
    } else {
        [completion setError:[NSError errorWithDomain:@"SettingView"
                                                 code:1
                                             userInfo:nil]];
    }

    return completion.task;
}


- (BFTask *)updateHackfoldrPageWithDialogController:(QuickDialogController *)dialogController key:(NSString *)hackfoldrKey
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

        self.tableView.dataSource = task.result;
        return nil;
    }];

    return completionSource.task;
}

- (HackfoldrTaskCompletionSource *)updateHackfoldrPageTaskWithKey:(NSString *)hackfoldrKey rediredKey:(NSString *)rediredKey
{
    NSString *key = hackfoldrKey;
    if (rediredKey) {
        key = rediredKey;
    }

    HackfoldrTaskCompletionSource *s = [[HackfoldrClient sharedClient] taskCompletionWithKey:key];
    [[s.task continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        HackfoldrPage *page = t.result;

        if (page.rediredKey) {
            NSLog(@"redired to:%@", page.rediredKey);
            return [self updateHackfoldrPageTaskWithKey:page.key rediredKey:page.rediredKey].task;
        }

        NSLog(@"page: %@", page);
        return [BFTask taskWithResult:page];
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        HackfoldrPage *page = t.result;

        // Save |history| to core data
        HackfoldrHistory *history = [HackfoldrHistory MR_findFirstByAttribute:@"hackfoldrKey" withValue:page.key];
        if (!history) {
            history = [HackfoldrHistory MR_createEntity];
            history.createDate = [NSDate date];
            history.refreshDate = [NSDate date];
            history.hackfoldrKey = page.key;
            history.title = page.pageTitle;
            if (page.rediredKey) {
                history.rediredKey = page.rediredKey;
            }
        } else {
            history.refreshDate = [NSDate date];
            history.title = page.pageTitle;
            if (page.rediredKey) {
                history.rediredKey = page.rediredKey;
            }
        }

        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:nil];
        return nil;
    }];
    return s;
}

- (void)settingAction:(id)sender
{
    [self showSettingViewController];
}

- (void)updateHackfoldrPageWithKey:(NSString *)hackfoldrKey
{
    [self updateHackfoldrPageWithDialogController:self.dialogController key:hackfoldrKey];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        __weak HackfoldrPage *dataSourcePage = (HackfoldrPage *)tableView.dataSource;
        HackfoldrField *sectionOfField = dataSourcePage.cells[indexPath.section];
        HackfoldrField *rowOfField = sectionOfField.subFields[indexPath.row];
        NSString *urlString = rowOfField.urlString;
        NSLog(@"url: %@", urlString);

        if (!urlString || urlString.length == 0) {
            // TODO: show nil message
            return;
        }

        NSURL *targetURL = [NSURL URLWithString:urlString];

        if ([NSURL canHandleHackfoldrURL:targetURL]) {
            // Redirect to |urlString|
            NSRange range = [urlString rangeOfString:@"://"];
            if (range.location != NSNotFound) {
                NSString *realKey = [urlString substringWithRange:NSMakeRange(range.location + range.length, urlString.length - range.length - range.location)];
                NSString *pKey = [[NSUserDefaults standardUserDefaults] hackfoldrPageKey];
                [[self updateHackfoldrPageTaskWithKey:realKey rediredKey:nil].task continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                    HackfoldrPage *page = t.result;

                    [[NSUserDefaults standardUserDefaults] setCurrentHackfoldrPage:realKey];

                    ListFieldViewController *lvc = [[ListFieldViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    lvc.tableView.dataSource = page;
                    [self.navigationController pushViewController:lvc animated:YES];
                    return nil;
                }];
                return;
            }
        }

        if (NSClassFromString(@"SFSafariViewController")) {
            SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:targetURL];
            svc.title = rowOfField.name;
            [self presentViewController:svc animated:YES completion:nil];
        } else {
            TOWebViewController *webViewController = [[TOWebViewController alloc] init];
            webViewController.showPageTitles = YES;
            [webViewController loadWithField:rowOfField];

            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
}

@end

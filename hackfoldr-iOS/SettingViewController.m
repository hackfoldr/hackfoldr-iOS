//
//  SettingViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2017/11/2.
//  Copyright © 2017年 org.g0v. All rights reserved.
//

#import "SettingViewController.h"

#import <Bolts/Bolts.h>

// Model & Client
#import <MagicalRecord/MagicalRecord.h>
#import "HackfoldrClient.h"
#import "HackfoldrHistory.h"
#import "HackfoldrPage.h"

// Cateogry
#import "NSURL+Hackfoldr.h"
#import "NSUserDefaults+DefaultHackfoldrPage.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (instancetype)init {
    if (self = [super init]) {
        [self configure];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configure {
    QRootElement *settingRoot = [[QRootElement alloc] init];
    settingRoot.title = NSLocalizedStringFromTable(@"Setting Hackfoldr Page", @"Hackfoldr", @"Title of SettingView");
    settingRoot.grouped = YES;

    QSection *currentPageSection = [[QSection alloc] init];
    currentPageSection.title = NSLocalizedStringFromTable(@"Current Hackfoldr", @"Hackfoldr", @"Section title of current hackfoldr");
    NSString *key = [[NSUserDefaults standardUserDefaults] stringOfCurrentHackfoldrPage];
    QLabelElement *currentHackpageKey = [[QLabelElement alloc] init];
    currentHackpageKey.title = NSLocalizedStringFromTable(@"Current key", @"Hackfoldr", @"Current key title in SettingView.");
    currentHackpageKey.value = key;
    [currentPageSection addElement:currentHackpageKey];

    QDateTimeElement *currentHackpageDate = [[QDateTimeElement alloc] init];
    HackfoldrHistory *currentHistory = [HackfoldrHistory MR_findFirstByAttribute:@"hackfoldrKey" withValue:key];
    currentHackpageDate.title = NSLocalizedStringFromTable(@"Refresh At", @"Hackfoldr", @"Refresh date about current hackfoldr key in SettingView.");
    currentHackpageDate.dateValue = currentHistory.refreshDate;
    currentHackpageDate.enabled = NO;
    [currentPageSection addElement:currentHackpageDate];

    [settingRoot addSection:currentPageSection];

    QSection *inputSection = [[QSection alloc] init];
    inputSection.footer = NSLocalizedStringFromTable(@"You can input new hackfoldr page key and select Change Key to change it.", @"Hackfoldr", @"Change key description at input section in SettingView.");

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
                self.updateHackfoldrPage(inputElement.textValue, task.error);
                return nil;
            }
            if (self.updateHackfoldrPage) {
                self.updateHackfoldrPage(task.result, nil);
            }

            return nil;;
        }];
    };
    [inputSection addElement:sendButtonElement];
    [settingRoot addSection:inputSection];

    QSection *historySection = [[QSection alloc] init];
    historySection.title = NSLocalizedStringFromTable(@"History", @"Hackfoldr", @"History section title in SettingView");
    historySection.footer = NSLocalizedStringFromTable(@"You can select one cell to return to the past.", @"Hackfoldr", @"History section footer in SettingView");
    NSArray<HackfoldrHistory *> *histories = [HackfoldrHistory MR_findAllSortedBy:@"refreshDate" ascending:NO];
    [histories enumerateObjectsUsingBlock:^(HackfoldrHistory *history, NSUInteger idx, BOOL *stop) {
        QButtonElement *buttonElement = [[QButtonElement alloc] init];
        buttonElement.title = history.title;
        buttonElement.onSelected = ^() {
            if (self.updateHackfoldrPage) {
                self.updateHackfoldrPage(history.hackfoldrKey, nil);
            }
        };
        [historySection addElement:buttonElement];
    }];
    [settingRoot addSection:historySection];

    QSection *restSection = [[QSection alloc] init];
    restSection.title = NSLocalizedStringFromTable(@"Reset Actions", @"Hackfoldr", @"Reset hackfoldr actions in SettingView");
    restSection.footer = NSLocalizedStringFromTable(@"If you lost in app, just select it.", @"Hackfoldr", @"Reset section footer in SettingView");
    QButtonElement *restHackfoldrPageElement = [[QButtonElement alloc] init];
    restHackfoldrPageElement.title = NSLocalizedStringFromTable(@"Hackfoldr Help", @"Hackfoldr", @"Reset hackfoldr page button title in SettingView");
    restHackfoldrPageElement.onSelected = ^(void) {
        // Set current HackfoldrPage to |DefaultHackfoldrPage|
        NSString *defaultHackfoldrKey = [[NSUserDefaults standardUserDefaults] stringOfDefaultHackfoldrPage];
        if (self.updateHackfoldrPage) {
            self.updateHackfoldrPage(defaultHackfoldrKey, nil);
        }
    };
    [restSection addElement:restHackfoldrPageElement];
    [settingRoot addSection:restSection];

    QSection *infoSection = [[QSection alloc] init];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    infoSection.footer = [NSString stringWithFormat:@"App Version: %@ (%@)\nCreate by Superbil", version, build];
    [settingRoot addSection:infoSection];

    self.root = settingRoot;
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

@end

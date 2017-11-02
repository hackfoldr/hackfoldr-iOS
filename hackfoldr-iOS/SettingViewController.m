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
    XLFormDescriptor *form = [self settingForm];
    if (self = [super initWithForm:form]) {
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

- (XLFormDescriptor *)settingForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:NSLocalizedStringFromTable(@"Setting Hackfoldr Page", @"Hackfoldr", @"Title of SettingView")];

    XLFormSectionDescriptor *currentPageSection = [XLFormSectionDescriptor formSection];
    currentPageSection.title = NSLocalizedStringFromTable(@"Current Hackfoldr", @"Hackfoldr", @"Section title of current hackfoldr");
    NSString *key = [[NSUserDefaults standardUserDefaults] stringOfCurrentHackfoldrPage];
    XLFormRowDescriptor *currentHackpageKey = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeInfo];
    currentHackpageKey.title = NSLocalizedStringFromTable(@"Current key", @"Hackfoldr", @"Current key title in SettingView.");
    currentHackpageKey.value = key;
    [currentPageSection addFormRow:currentHackpageKey];

    XLFormRowDescriptor *currentHackpageDate = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeDate];
    HackfoldrHistory *currentHistory = [HackfoldrHistory MR_findFirstByAttribute:@"hackfoldrKey" withValue:key];
    currentHackpageDate.title = NSLocalizedStringFromTable(@"Refresh At", @"Hackfoldr", @"Refresh date about current hackfoldr key in SettingView.");
    currentHackpageDate.value = currentHistory.refreshDate;
    currentHackpageDate.disabled = @YES;
    [currentPageSection addFormRow:currentHackpageDate];

    [form addFormSection:currentPageSection];

    XLFormSectionDescriptor *inputSection = [XLFormSectionDescriptor formSection];
    inputSection.footerTitle = NSLocalizedStringFromTable(@"You can input new hackfoldr page key and select Change Key to change it.", @"Hackfoldr", @"Change key description at input section in SettingView.");

    XLFormRowDescriptor *inputRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"hackfoldrKey" rowType:XLFormRowDescriptorTypeText];
    inputRow.cellConfig[@"textField.placeholder"] = NSLocalizedStringFromTable(@"Hackfoldr key or URL", @"Hackfoldr", @"Place holder string for input element in SettingView.");
    [inputSection addFormRow:inputRow];

    XLFormRowDescriptor *sendButton = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeButton];
    sendButton.title = NSLocalizedStringFromTable(@"Change Key", @"Hackfoldr", @"Change hackfoldr key button title in SettingView.");
    // Change page button clicked
    sendButton.action.formBlock = ^(XLFormRowDescriptor * _Nonnull sender) {
        NSString *inputText = form.formValues[@"hackfoldrKey"];
        BFTask *cleanKeyTask = [self validatorHackfoldrKeyForSettingViewWithHackfoldrKey:inputText];
        [cleanKeyTask continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                self.updateHackfoldrPage(inputText, task.error);
                return nil;
            }
            if (self.updateHackfoldrPage) {
                self.updateHackfoldrPage(task.result, nil);
            }

            return nil;;
        }];
    };
    [inputSection addFormRow:sendButton];
    [form addFormSection:inputSection];

    XLFormSectionDescriptor *historySection = [XLFormSectionDescriptor formSection];
    historySection.title = NSLocalizedStringFromTable(@"History", @"Hackfoldr", @"History section title in SettingView");
    historySection.footerTitle = NSLocalizedStringFromTable(@"You can select one cell to return to the past.", @"Hackfoldr", @"History section footer in SettingView");
    NSArray<HackfoldrHistory *> *histories = [HackfoldrHistory MR_findAllSortedBy:@"refreshDate" ascending:NO];
    [histories enumerateObjectsUsingBlock:^(HackfoldrHistory *history, NSUInteger idx, BOOL *stop) {
        XLFormRowDescriptor *historyButton = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeButton];
        historyButton.title = history.title;
        historyButton.action.formBlock = ^(XLFormRowDescriptor * _Nonnull sender) {
            if (self.updateHackfoldrPage) {
                self.updateHackfoldrPage(history.hackfoldrKey, nil);
            }
        };
        [historySection addFormRow:historyButton];
    }];
    [form addFormSection:historySection];

    XLFormSectionDescriptor *resetSection = [XLFormSectionDescriptor formSection];
    resetSection.title = NSLocalizedStringFromTable(@"Reset Actions", @"Hackfoldr", @"Reset hackfoldr actions in SettingView");
    resetSection.footerTitle = NSLocalizedStringFromTable(@"If you lost in app, just select it.", @"Hackfoldr", @"Reset section footer in SettingView");
    XLFormRowDescriptor *restHackfoldrPageButton = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeButton];
    restHackfoldrPageButton.title = NSLocalizedStringFromTable(@"Hackfoldr Help", @"Hackfoldr", @"Reset hackfoldr page button title in SettingView");
    restHackfoldrPageButton.action.formBlock = ^(XLFormRowDescriptor * _Nonnull sender) {
        // Set current HackfoldrPage to |DefaultHackfoldrPage|
        NSString *defaultHackfoldrKey = [[NSUserDefaults standardUserDefaults] stringOfDefaultHackfoldrPage];
        if (self.updateHackfoldrPage) {
            self.updateHackfoldrPage(defaultHackfoldrKey, nil);
        }
    };
    [resetSection addFormRow:restHackfoldrPageButton];
    [form addFormSection:resetSection];

    XLFormSectionDescriptor *infoSection = [XLFormSectionDescriptor formSection];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    infoSection.footerTitle = [NSString stringWithFormat:@"App Version: %@ (%@)\nCreate by Superbil", version, build];
    [form addFormSection:infoSection];

    return form;
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

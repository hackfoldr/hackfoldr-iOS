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

// View Controller
#import "QRCodeViewController.h"

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

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
    [self.navigationController.navigationBar.topItem setRightBarButtonItem:shareItem animated:animated];
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
    XLFormRowDescriptor *addButton = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeButton];
    addButton.title = NSLocalizedStringFromTable(@"Add Hackfoldr Page", @"Hackfoldr", @"'Add Hackfoldr Page' button title");
    __weak XLFormRowDescriptor *wab = addButton;
    addButton.action.formBlock = ^(XLFormRowDescriptor * _Nonnull sender) {
        void (^deselectCell)(void) = ^() {
            UITableViewCell *cell = [sender cellForFormController:self];
            NSIndexPath *indexPathOfCell = [self.tableView indexPathForCell:cell];
            [self.tableView deselectRowAtIndexPath:indexPathOfCell animated:YES];
        };

        __strong XLFormRowDescriptor *sab = wab;
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                    message:NSLocalizedStringFromTable(@"Select a way to input new key", @"Hackfoldr", @"Message for 'Add Hackfolr Page'")
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
        [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Hackfoldr key or URL", @"Hackfoldr", @"Place holder string for input element in SettingView.") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // Show an alert with textField
            UIAlertController *inputAlert = [UIAlertController alertControllerWithTitle:sab.title
                                                                                message:nil
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            NSString *changeKey = NSLocalizedStringFromTable(@"Change Key", @"Hackfoldr", @"Change hackfoldr key button title in SettingView.");
            [inputAlert addAction:[UIAlertAction actionWithTitle:changeKey style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                if (inputAlert.textFields.count == 0) return;

                UITextField *textField = inputAlert.textFields.firstObject;
                BFTask *cleanKeyTask = [self validatorHackfoldrKeyForSettingViewWithHackfoldrKey:textField.text];
                [cleanKeyTask continueWithBlock:^id(BFTask *task) {
                    if (task.error) {
                        self.updateHackfoldrPage(textField.text, task.error);
                        return nil;
                    }
                    if (self.updateHackfoldrPage) {
                        self.updateHackfoldrPage(task.result, nil);
                    }
                    return nil;
                }];
            }]];
            [inputAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = action.title;
            }];
            [self presentViewController:inputAlert animated:YES completion:deselectCell];
        }]];
        [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Scan QR Code", @"Hackfoldr", @"Scan QR code button title") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // Show scaner
            QRCodeViewController *qvc = [QRCodeViewController viewController];
            qvc.foundedResult = ^(NSString *result) {
                [self.navigationController popViewControllerAnimated:YES];

                BFTask *cleanKeyTask = [self validatorHackfoldrKeyForSettingViewWithHackfoldrKey:result];
                [cleanKeyTask continueWithBlock:^id(BFTask *t) {
                    if (t.error) {
                        self.updateHackfoldrPage(t.result, t.error);
                        return nil;
                    }
                    if (self.updateHackfoldrPage) {
                        self.updateHackfoldrPage(t.result, nil);
                    }
                    return nil;
                }];
            };
            [self.navigationController pushViewController:qvc animated:YES];
            deselectCell();
        }]];
        [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"Hackfoldr", @"Cancel button title of 'Add Hackfoldr Page'") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            deselectCell();
        }]];
        [self presentViewController:ac animated:YES completion:nil];
    };
    [inputSection addFormRow:addButton];

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

- (void)shareAction {
    QRCodeViewController *qrvc = [QRCodeViewController viewController];
    NSString *hackfoldrPageKey = [[NSUserDefaults standardUserDefaults] stringOfCurrentHackfoldrPage];
    qrvc.qrCodeString = [@"https://hackfoldr.org" stringByAppendingPathComponent:hackfoldrPageKey];
    [self.navigationController pushViewController:qrvc animated:YES];
}

@end

//
//  ListFieldViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/8/31.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "ListFieldViewController.h"

#import <Bolts/Bolts.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

// Model & Client
#import <MagicalRecord/MagicalRecord.h>
#import "HackfoldrClient.h"
#import "HackfoldrHistory.h"
#import "HackfoldrPage.h"
// Category
#import "NSUserDefaults+DefaultHackfoldrPage.h"
#import "NSURL+Hackfoldr.h"
#import "UIColor+Hackfoldr.h"
#import "UIImage+TOWebViewControllerIcons.h"
// ViewController
#import <RATreeView/RATreeView.h>
#import <SafariServices/SafariServices.h>
#import "ListFieldViewController.h"
#import "QuickDialog.h"
#import "TOWebViewController+HackfoldrField.h"
#import "UIAlertView+AFNetworking.h"

@interface ListFieldViewController () <RATreeViewDelegate, RATreeViewDataSource>
@property (nonatomic, strong) QuickDialogController *dialogController;
@end

@implementation ListFieldViewController

+ (instancetype)viewController
{
    return [[[self class] alloc] initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _hideBackButton = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.treeView = [[RATreeView alloc] initWithFrame:self.view.bounds style:RATreeViewStylePlain];
    self.treeView.delegate = self;
    self.treeView.dataSource = self;
    self.treeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.treeView];

    self.settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingButton addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    int iconSize = 26;
    [self.settingButton setImage: [[FAKFontAwesome cogIconWithSize:iconSize] imageWithSize:CGSizeMake(iconSize, iconSize)] forState:UIControlStateNormal];
    self.settingButton.frame = CGRectMake(0, 0, iconSize, iconSize);
    self.settingButton.accessibilityLabel = @"Settings";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.settingButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Hide back button
    if (self.hideBackButton) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    }

    [super viewWillAppear:animated];

    self.title = self.page.pageTitle;
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
                [self reloadPage];

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
                [self reloadPage];

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
            [self reloadPage];

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

        HackfoldrPage *page = task.result;
        self.page = page;
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
    [[[s.task continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        HackfoldrPage *page = t.result;

        if (page.rediredKey) {
            NSLog(@"redired to:%@", page.rediredKey);
            return [self updateHackfoldrPageTaskWithKey:page.key rediredKey:page.rediredKey].task;
        }

        NSLog(@"page: %@", page);
        return t;
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
        return t;
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        self.page = t.result;
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

- (void)reloadPage {
    if (!self.page) return;

    [self.treeView reloadData];

    // Just a little delay to workaround UI display
    [[BFTask taskWithDelay:100] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        // Expand field cells
        for (HackfoldrField *f in self.page.cells) {
            if (f.actions && [f.actions rangeOfString:@"expand"].location != NSNotFound) {
                [self.treeView expandRowForItem:f];
            }
        }
        return nil;
    }];
}

- (UIImage *)folderImageWithField:(HackfoldrField *)field
{
    if (field.actions && [field.actions rangeOfString:@"expand"].location != NSNotFound) {
        return [self folderImageWithisExpand:YES];
    }
    return [self folderImageWithisExpand:NO];
}

- (UIImage *)folderImageWithisExpand:(BOOL)isExpand
{
    CGFloat iconSize = 24;
    UIImage *foldrImage;
    if (isExpand) {
        foldrImage = [[FAKFontAwesome folderOpenIconWithSize:iconSize] imageWithSize:CGSizeMake(iconSize, iconSize)];
    } else {
        foldrImage = [[FAKFontAwesome folderIconWithSize:iconSize] imageWithSize:CGSizeMake(iconSize, iconSize)];
    }
    return foldrImage;
}

#pragma mark - RATreeViewDelegate

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item
{
    HackfoldrField *rowOfField = item;
    if (!rowOfField.isSubItem) {
        return;
    }

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
            NSString *realKey = [NSURL realKeyOfHackfoldrWithURL:targetURL];
            if (!realKey) return;

            [[self updateHackfoldrPageTaskWithKey:realKey rediredKey:nil].task continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                HackfoldrPage *page = t.result;

                [[NSUserDefaults standardUserDefaults] setCurrentHackfoldrPage:realKey];

                ListFieldViewController *lvc = [ListFieldViewController viewController];
                lvc.hideBackButton = NO;
                lvc.page = page;
                [self.navigationController pushViewController:lvc animated:YES];
                [lvc reloadPage];
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

- (BOOL)treeView:(RATreeView *)treeView shouldExpandRowForItem:(id)item
{
    if (item) {
        NSInteger subIndex = [self.page.cells indexOfObject:item];
        return (subIndex != NSNotFound);
    }
    return YES;
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item
{
    UITableViewCell *cell = [treeView cellForItem:item];
    cell.imageView.image = [self folderImageWithisExpand:YES];
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item
{
    UITableViewCell *cell = [treeView cellForItem:item];
    cell.imageView.image = [self folderImageWithisExpand:NO];
}

#pragma mark - RATreeViewDataSource

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(nullable id)item;
{
    if (item) {
        NSInteger subIndex = [self.page.cells indexOfObject:item];
        HackfoldrField *subField = self.page.cells[subIndex];
        return subField.subFields.count;
    }

    // Root items
    NSUInteger sum = 0;
    for (HackfoldrField *f in self.page.cells) {
        if (f.index == 0) {
            sum += f.subFields.count;
        } else if (!f.isSubItem) {
            sum += 1;
        }
    }
    return sum;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(nullable id)item
{
    if (item) {
        HackfoldrField *field = item;
        return field.subFields[index];
    }

    HackfoldrField *rootField = nil;
    for (HackfoldrField *f in self.page.cells) {
        if (f.index == 0) {
            rootField = f;
        } else {
            break;
        }
    }
    if (rootField) {
        if (index < rootField.subFields.count) {
            return rootField.subFields[index];
        }
        NSInteger realIndex = index - (rootField.subFields.count - 1);
        if (rootField && rootField.subFields.count > 0 && realIndex == 0) {
            realIndex += 1;
        }
        return self.page.cells[realIndex];
    }
    return self.page.cells[index];
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(nullable id)item;
{
    HackfoldrField *field = item;
    NSString *cellName = field.isSubItem ? @"detail" : @"folder";
    NSString *identifier = [cellName stringByAppendingString:@"Cell"];
    UITableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    // Default color is white
    cell.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];

    CGFloat fontSize = [UIFont systemFontSize];

    if (field.isSubItem) {
        UIImage *iconImage = nil;
        CGFloat iconSize = [UIFont systemFontSize] + 2.f;

        if ([NSURL canHandleHackfoldrURL:[NSURL URLWithString:field.urlString]]) {
            iconImage = [[UIImage imageNamed:@"hackfoldr-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else if (field.actions.length > 0 && [field.actions rangeOfString:@"fa-"].location != NSNotFound) {
            // Custom icon
            NSString *iconName = nil;
            NSArray<NSString *> *actions = [field.actions componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            for (NSString *s in actions) {
                if ([s rangeOfString:@"fa-"].location != NSNotFound) {
                    iconName = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    break;
                }
            }

            NSError *error = nil;
            FAKFontAwesome *fa = [FAKFontAwesome iconWithIdentifier:iconName size:iconSize error:&error];
            if (!error) {
                iconImage = [fa imageWithSize:CGSizeMake(iconSize, iconSize)];
            } else {
                NSLog(@"FontAwsome %@, %@", iconName, error);
            }
        }

        if (iconImage) {
            UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
            iconView.frame = CGRectMake(0, 0, iconSize, iconSize);
            iconView.tintColor = [UIColor hackfoldrGreenColor];
            cell.accessoryView = iconView;
        } else {
            cell.accessoryType = field.urlString.length > 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
        }

        // Only setup when |field.labelString| have value
        NSString *cleanLabelString = [field.labelString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (cleanLabelString.length > 0) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@" %@ ", field.labelString];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = field.labelColor;
            [cell.detailTextLabel.layer setCornerRadius:3.f];
            [cell.detailTextLabel.layer setMasksToBounds:YES];
        } else {
            cell.detailTextLabel.text = nil;
        }
    } else {
        cell.detailTextLabel.text = nil;
        fontSize += 4.f;

        cell.imageView.image = [self folderImageWithField:field];
    }

    cell.textLabel.text = field.name;
    cell.textLabel.font = [UIFont systemFontOfSize:fontSize];

    NSLog(@"field:%@", field);

    return cell;
}

@end

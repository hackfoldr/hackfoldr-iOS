//
//  SettingViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/10/11.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "SettingViewController.h"

#import "NSUserDefaults+DefaultHackfoldrPage.h"
#import "HackfoldrClient.h"

#import "UIAlertView+AFNetworking.h"

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) UITableView *pageListView;
@property (nonatomic, strong) UITextView *hackfoldrPageTextView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedStringFromTable(@"Change Hackfoldr Page", @"Hackfoldr", @"Title of SettingView");
    self.view.backgroundColor = [UIColor whiteColor];

    self.pageListView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.pageListView.dataSource = self;
    self.pageListView.delegate = self;
    [self.view addSubview:self.pageListView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateHackfoldrPage:(id)sender {
    NSString *newHackfoldrPage = self.hackfoldrPageTextView.text;
    if (newHackfoldrPage && newHackfoldrPage.length > 0) {
        // Check |newHackfoldrPage| is existed
        HackfoldrTaskCompletionSource *completionSource = [[HackfoldrClient sharedClient] taskCompletionPagaDataAtPath:newHackfoldrPage];
        [UIAlertView showAlertViewForTaskWithErrorOnCompletion:completionSource.connectionTask delegate:nil];
        [completionSource.task continueWithSuccessBlock:^id(BFTask *task) {
            NSLog(@"change hackfoldr page: %@", newHackfoldrPage);
            [[NSUserDefaults standardUserDefaults] setCurrentHackfoldrPage:newHackfoldrPage];
            return nil;
        }];
    }

    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"HFSettingViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = @"";

    if (indexPath.section == 0 && indexPath.row == 0) {
        UITextView *hackfoldrPageTextView = [[UITextView alloc] initWithFrame:cell.frame];
        hackfoldrPageTextView.delegate = self;
        [cell.contentView addSubview:hackfoldrPageTextView];
        self.hackfoldrPageTextView = hackfoldrPageTextView;
    }

    // Update hackfoldr page cell
    if (indexPath.section == 0 && indexPath.row == 1) {
        NSString *updateButtonTitle = NSLocalizedStringFromTable(@"Change page", @"Hackfoldr", @"update hackfoldr button text");
        cell.textLabel.text = updateButtonTitle;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSLog(@"touch textview");
    }

    if (indexPath.section == 0 && indexPath.row == 1) {
        [self updateHackfoldrPage:self];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    // this method is called every time you touch in the textView, provided it's editable;
    NSIndexPath *indexPath = [self.pageListView indexPathForCell:(UITableViewCell *)textView.superview.superview];
    // i know that looks a bit obscure, but calling superview the first time finds the contentView of your cell;
    //  calling it the second time returns the cell it's held in, which we can retrieve an index path from;

    // this is the edited part;
    [self.pageListView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    // this programmatically selects the cell you've called behind the textView;

    [self tableView:self.pageListView didSelectRowAtIndexPath:indexPath];
    // this selects the cell under the textView;
    return YES;
}

@end

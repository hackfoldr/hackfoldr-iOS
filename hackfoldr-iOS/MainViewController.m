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

    self.listViewController = [[ListFieldViewController alloc] init];
    self.listViewController.tableView.delegate = self;

    self.webViewController = [[TOWebViewController alloc] init];
    if (self.webViewController) {
        [self.view addSubview:self.webViewController.view];
    }

    UIImage *backgroundImage =  [UIImage imageNamed:@"LaunchImage-700"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];

    if (backgroundImageView) {
        [self.view addSubview:backgroundImageView];
    }
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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

- (void)loadWithField:(HackfoldrField *)field
{
    [self presentViewController:self.webViewController animated:YES completion:^{
        [self.webViewController loadWithField:field];
        self.currentField = field;
    }];
}

#pragma mark - Actions

- (void)showListViewController {
    UINavigationController *navigationControllerForListViewController =
    [[UINavigationController alloc] initWithRootViewController:self.listViewController];
    [self presentViewController:navigationControllerForListViewController animated:YES completion:nil];
}

- (void)settingAction:(id)sender
{
    NSLog(@"setting button clicked");
    // TODO: remove storyboard
    UIViewController *editViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"editViewController"];
    [self.navigationController pushViewController:editViewController animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HackfoldrField *field = [HackfoldrClient sharedClient].lastPage.cells[indexPath.row];
    NSString *urlString = field.urlString;
    NSLog(@"url: %@", urlString);

    if (urlString && urlString.length == 0) {
        return;
    }

    [self loadWithField:field];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

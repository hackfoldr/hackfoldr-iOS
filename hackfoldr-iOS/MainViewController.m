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

static NSString *kDefaultHackfoldrPage = @"Default Hackfolder Page";

@interface MainViewController () <UITableViewDelegate>

@property (nonatomic, strong) TOWebViewController *webViewController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) ListFieldViewController *listViewController;
@end

@implementation MainViewController

- (void)awakeFromNib
{
    self.listViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"listViewController"];
    self.webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    UIImage *backgroundImage =  [UIImage imageNamed:@"LaunchImage-700"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];

    if (backgroundImageView) {
    }

    self.view.backgroundColor = [UIColor blueColor];
    self.listViewController.tableView.delegate = self;
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
            [self presentViewController:self.listViewController animated:YES completion:nil];
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

@end

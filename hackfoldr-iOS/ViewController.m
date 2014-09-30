//
//  ViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/21.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "ViewController.h"

// Model & Client
#import "HackfoldrClient.h"
#import "HackfoldrPage.h"
// ViewController
#import "TOWebViewController+HackfoldrField.h"
#import "UIViewController+JASidePanel.h"

static NSString *kDefaultHackfoldrPage = @"Default Hackfolder Page";

@interface ViewController () <UITableViewDelegate>

@property (nonatomic, strong) TOWebViewController *webViewController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UITableViewController *leftViewController;
@end

@implementation ViewController

- (void)awakeFromNib
{
    self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"listViewController"];
    self.webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"centerViewController"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.webViewController];

    UIImage *backgroundImage =  [UIImage imageNamed:@"LaunchImage-700"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];

    if (backgroundImageView) {
        [self.webViewController.view addSubview:backgroundImageView];
    }

    [self setLeftPanel:self.leftViewController];
    [self setCenterPanel:self.navigationController];

    self.leftViewController.tableView.delegate = self;
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
        self.leftViewController.tableView.dataSource = [HackfoldrClient sharedClient].lastPage;

        [self.leftViewController.tableView reloadData];
        return nil;
    }];
}

- (void)loadWithField:(HackfoldrField *)field
{
    [self.webViewController loadWithField:field];
    [self showCenterPanelAnimated:YES];
}

@end

//
//  ViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/21.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "ViewController.h"

// Model & Client
#import "HackfolerClient.h"
#import "HackfolerPage.h"
// ViewController
#import "TOWebViewController+HackfolerField.h"
#import "UIViewController+JASidePanel.h"

static NSString *kDefaultHackfolerPage = @"Default Hackfolder Page";

@interface ViewController () <UITableViewDelegate>

@property (nonatomic, strong) TOWebViewController *webViewController;
@property (nonatomic, strong) HackfolerPage *currentPage;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UITableViewController *leftViewController;

@end

@implementation ViewController

- (void)awakeFromNib
{
    self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
    self.webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"centerViewController"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.webViewController];

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
    NSString *pageKey = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultHackfolerPage];

    if (!pageKey || pageKey.length == 0) {
        NSString *defaultPage = @"kuansim";

        [[NSUserDefaults standardUserDefaults] setObject:defaultPage forKey:kDefaultHackfolerPage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        pageKey = defaultPage;
    }

    return pageKey;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[[HackfolerClient sharedClient] pagaDataAtPath:self.hackfoldrPageKey] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"error:%@", task.error);
        }

        NSLog(@"%@", task.result);
        self.currentPage = task.result;
        self.leftViewController.tableView.dataSource = self.currentPage;

        [self.leftViewController.tableView reloadData];
        return nil;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HackfolerField *field = (HackfolerField *)self.currentPage.cells[indexPath.row];
    NSString *urlString = field.urlString;
    NSLog(@"url: %@", urlString);

    if (urlString && urlString.length == 0) {
        return;
    }

    [self.webViewController loadWithField:field];
    [self showCenterPanelAnimated:YES];
}

@end

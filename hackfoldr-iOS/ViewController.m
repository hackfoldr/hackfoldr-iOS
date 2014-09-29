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

    [self setLeftPanel:self.leftViewController];
    [self setCenterPanel:self.navigationController];

    self.leftViewController.tableView.delegate = self;
    
    
    self.webViewController.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showSettings)];
;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[[HackfoldrClient sharedClient] getPageData] continueWithBlock:^id(BFTask *task) {
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

- (void) showSettings{

    UIViewController *pVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editViewController"];
    [self.navigationController pushViewController:pVC animated:YES];
    
}


@end

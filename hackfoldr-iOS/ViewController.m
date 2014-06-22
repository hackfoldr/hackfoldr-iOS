//
//  ViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/21.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "ViewController.h"

#import "HackfolerClient.h"
#import "HackfolerPage.h"
#import "NJKWebViewProgress.h"
#import "UIWebView+Blocks.h"
#import "UIViewController+JASidePanel.h"

@interface ViewController () <UITableViewDelegate>

@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) UITableViewController *leftViewController;
@property (nonatomic, strong) HackfolerPage *currentPage;

@end

@implementation ViewController

- (void)awakeFromNib
{
    self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
    self.centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"centerViewController"];

    [self setLeftPanel:self.leftViewController];
    [self setCenterPanel:self.centerViewController];

    self.leftViewController.tableView.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[[HackfolerClient sharedClient] pagaDataAtPath:@"kuansim"] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"error:%@", task.error);
        }

        NSLog(@"task.result:%@", task.result);
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

    if (urlString && urlString.length == 0) {
        return;
    }
    NSLog(@"url: %@", urlString);

    UIWebView *webView =
    [UIWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                    loaded:^(UIWebView *webView) {
                        NSLog(@"Loaded successfully");
                    }
                    failed:^(UIWebView *webView, NSError *error) {
                        NSLog(@"Failed loading %@", error);
                    }];

    self.view = webView;
}

@end

//
//  CenterViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/24.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "CenterViewController.h"

#import "HackfolerPage.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface CenterViewController () <NJKWebViewProgressDelegate>
@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UIView *logo;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@end

@implementation CenterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.progressProxy.progressDelegate = self;
    self.webView.delegate = self.progressProxy;

    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    self.progressView.progress = 0.f;
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.progressView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationBar.hidden = YES;
}

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:NO];
}

- (void)loadWithField:(HackfolerField *)oneField
{
    self.logo.hidden = YES;

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:oneField.urlString]]];
}

@end

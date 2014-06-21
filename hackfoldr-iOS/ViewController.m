//
//  ViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/21.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "ViewController.h"

#import "AFNetworking.h"
#import "Bolts.h"
#import "CHCSVParser.h"


#import "NJKWebViewProgress.h"
#import "UIWebView+Blocks.h"
#import "UIViewController+JASidePanel.h"

@interface G0VABTaskCompletionSource : BFTaskCompletionSource
+ (G0VABTaskCompletionSource *)taskCompletionSource;
@property (strong, nonatomic) NSURLSessionTask *connectionTask;

@end

@implementation G0VABTaskCompletionSource

+ (G0VABTaskCompletionSource *)taskCompletionSource
{
	return [[G0VABTaskCompletionSource alloc] init];
}

- (void)dealloc
{
	[self.connectionTask cancel];
	self.connectionTask = nil;
}

- (void)cancel
{
	[self.connectionTask cancel];
	[super cancel];
}

@end

#pragma mark -

@interface HackfolerClient : AFHTTPSessionManager

@end

@implementation HackfolerClient

+ (instancetype)sharedClient
{
    static dispatch_once_t onceToken;
    static HackfolerClient *shareClient;
    dispatch_once(&onceToken, ^{
        shareClient = [[HackfolerClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://ethercalc.org/_/"]];
    });
    return shareClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
		self.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (BFTask *)_taskWithPath:(NSString *)inPath parameters:(NSDictionary *)parameters
{
	G0VABTaskCompletionSource *source = [G0VABTaskCompletionSource taskCompletionSource];
	source.connectionTask = [self GET:inPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
		if (responseObject) {

            NSString *stringData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
//            NSLog(@"rawData:%@", stringData);

            CHCSVParser *csvParser = [[CHCSVParser alloc] initWithCSVString:stringData];
            if (csvParser) {
                [source setResult:csvParser];
            } else {
                NSLog(@"parser create failed");
                [source setError:[NSError errorWithDomain:@"ethercalc.org" code:0 userInfo:nil]];
            }

		}
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		[source setError:error];
	}];
	return source.task;
}

- (BFTask *)pagaDataAtPath:(NSString *)inPath
{
    return [self _taskWithPath:[NSString stringWithFormat:@"%@/csv", inPath] parameters:nil];
}

@end

@interface HackfolerField : NSObject

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *actions;

- (BOOL)isEmpty;

@end

@implementation HackfolerField

- (BOOL)isEmpty
{
    if (!self.urlString && !self.name && !self.actions) {
        return YES;
    }
    
    if (self.urlString.length == 0 && self.name.length == 0 && self.actions.length == 0) {
        return YES;
    }
    
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name:%@ url:%@ actions:%@", self.name, self.urlString, self.actions];
}

@end

#pragma mark -

@interface ViewController () <CHCSVParserDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) HackfolerField *oneField;

@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) UITableViewController *leftViewController;

@end

@implementation ViewController

- (void)awakeFromNib
{
    self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
    self.centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"centerViewController"];

    [self setLeftPanel:self.leftViewController];
    [self setCenterPanel:self.centerViewController];

    self.leftViewController.tableView.dataSource = self;
    self.leftViewController.tableView.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.fields = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[HackfolerClient sharedClient] pagaDataAtPath:@"kuansim"] continueWithBlock:^id(BFTask *task) {
        NSLog(@"error:%@", task.error);
        
        NSLog(@"task.result:%@", task.result);
        CHCSVParser *parser = (CHCSVParser *)task.result;
        parser.delegate = self;
//        parser.recognizesComments = YES;
//        parser.sanitizesFields = YES;
//        parser.recognizesBackslashesAsEscapes = YES;

        [parser parse];

        NSLog(@"done:%@", self.fields);
        [self.leftViewController.tableView reloadData];
        return nil;
    }];
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber
{
    self.oneField = [[HackfolerField alloc] init];
    self.oneField.index = recordNumber;
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber
{
    if (![self.oneField isEmpty]) {
        [self.fields addObject:self.oneField];
    }

    self.oneField = nil;
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex
{
    NSLog(@"field:%@, at %d", field, fieldIndex);
    switch (fieldIndex) {
        case 0:
            self.oneField.urlString = field;
            break;
        case 1:
            self.oneField.name = field;
            break;
        case 2:
            self.oneField.actions = field;
            break;
            
        default:
            break;
    }
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error
{
    NSLog(@"parser error:%@", error);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.textLabel.text = ((HackfolerField *)self.fields[indexPath.row]).name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = ((HackfolerField *)self.fields[indexPath.row]).urlString;
    NSLog(@"url:%@", urlString);

    if (urlString && urlString.length == 0) {
        return;
    }
    
    UIWebView *webView =
    [UIWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                    loaded:^(UIWebView *webView) {
                        NSLog(@"Loaded successfully");
                    }
                    failed:^(UIWebView *webView, NSError *error) {
                        NSLog(@"Failed loading %@", error);
                    }];
    
//    [self.view addSubview:webView];
//    self.view.backgroundColor = [UIColor clearColor];

    self.view = webView;

//    [self.sidePanelController setCenterPanelHidden:YES animated:YES duration:2.0f];
}

@end

//
//  HackfolerClient.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfolerClient.h"

#import "CHCSVParserResponseSerializer.h"

@interface HackfolerTaskCompletionSource : BFTaskCompletionSource

+ (HackfolerTaskCompletionSource *)taskCompletionSource;
@property (strong, nonatomic) NSURLSessionTask *connectionTask;

@end

@implementation HackfolerTaskCompletionSource

+ (HackfolerTaskCompletionSource *)taskCompletionSource
{
	return [[HackfolerTaskCompletionSource alloc] init];
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

@interface HackfolerClient ()
@property NSArray *fields;
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
		self.responseSerializer = [CHCSVParserResponseSerializer serializer];
    }
    return self;
}

- (BFTask *)_taskWithPath:(NSString *)inPath parameters:(NSDictionary *)parameters
{
	HackfolerTaskCompletionSource *source = [HackfolerTaskCompletionSource taskCompletionSource];
	source.connectionTask = [self GET:inPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
		if (responseObject) {
            NSLog(@"rawData:%@", responseObject);
            self.fields = responseObject;
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

#pragma mark - UITableViewDataSource

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

@end

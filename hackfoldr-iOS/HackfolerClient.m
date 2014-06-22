//
//  HackfolerClient.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfolerClient.h"

#import "CHCSVParserResponseSerializer.h"
#import "HackfolerPage.h"

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
	source.connectionTask = [self GET:inPath parameters:parameters success:^(NSURLSessionDataTask *task, id csvFieldArray) {
        HackfolerPage *page = [[HackfolerPage alloc] initWithFieldArray:csvFieldArray];
        [source setResult:page];
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

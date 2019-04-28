//
//  HackfoldrClient.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfoldrClient.h"

#import "AFCSVParserResponseSerializer.h"
#import "HackfoldrPage.h"

@implementation HackfoldrTaskCompletionSource

+ (HackfoldrTaskCompletionSource *)taskCompletionSource
{
	return [[HackfoldrTaskCompletionSource alloc] init];
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

@interface HackfoldrClient ()
@property (nonatomic, strong, readwrite) HackfoldrPage *lastPage;
@end

@implementation HackfoldrClient

+ (instancetype)sharedClient
{
    static dispatch_once_t onceToken;
    static HackfoldrClient *shareClient;
    dispatch_once(&onceToken, ^{
        shareClient = [[HackfoldrClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://ethercalc.org/"]];
    });
    return shareClient;
}

+ (AFCSVParserResponseSerializer *)CSVSerializer
{
    AFCSVParserResponseSerializer *serializer = [AFCSVParserResponseSerializer serializer];
    serializer.usedEncoding = NSUTF8StringEncoding;
    return serializer;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (HackfoldrTaskCompletionSource *)_taskCompletionWithPath:(NSString *)inPath
{
    HackfoldrTaskCompletionSource *source = [HackfoldrTaskCompletionSource taskCompletionSource];
    NSString *requestPath = [NSString stringWithFormat:@"%@.csv.json", inPath];
    source.connectionTask = [self GET:requestPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id fieldArray) {
        HackfoldrPage *page = [[HackfoldrPage alloc] initWithKey:inPath fieldArray:fieldArray];
        self->_lastPage = [page copy];
        [source setResult:self->_lastPage];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [source setError:error];
    }];
    return source;
}

- (HackfoldrTaskCompletionSource *)taskCompletionFromEthercalcWithKey:(NSString *)key
{
    return [self _taskCompletionWithPath:key];
}

- (HackfoldrTaskCompletionSource *)taskCompletionFromGoogleSheetWithSheetKey:(NSString *)keyID
{
    // example at https://docs.google.com/spreadsheets/d/176W720jq1zpjsOcsZTkSmwqhmm_hK4VFINK_aubF8sc/export?format=csv&gid=0
    HackfoldrTaskCompletionSource *source = [HackfoldrTaskCompletionSource taskCompletionSource];

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://docs.google.com/"]];
    manager.responseSerializer = [[self class] CSVSerializer];

    NSString *requestKeyID = [keyID stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString *requestPath = [NSString stringWithFormat:@"spreadsheets/d/%@/export?format=csv&gid=0", requestKeyID];
    source.connectionTask = [manager GET:requestPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id csvFieldArray) {
        HackfoldrPage *page = [[HackfoldrPage alloc] initWithKey:keyID fieldArray:csvFieldArray];
        self->_lastPage = [page copy];
        [source setResult:self->_lastPage];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@ %@", error, task.response);
        [source setError:error];
    }];

    return source;
}

- (HackfoldrTaskCompletionSource *)taskCompletionWithKey:(NSString *)hackfoldrKey
{
    HackfoldrTaskCompletionSource *completionSource = nil;
    // check where the data come from, ethercalc or gsheet
    if (hackfoldrKey.length < 40) {
        completionSource = [self taskCompletionFromEthercalcWithKey:hackfoldrKey];
    } else {
        completionSource = [self taskCompletionFromGoogleSheetWithSheetKey:hackfoldrKey];
    }

    return completionSource;
}

@end

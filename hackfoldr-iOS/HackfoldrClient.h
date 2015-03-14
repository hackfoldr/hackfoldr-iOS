//
//  HackfoldrClient.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "Bolts.h"

@class HackfoldrPage;

@interface HackfoldrTaskCompletionSource : BFTaskCompletionSource

+ (HackfoldrTaskCompletionSource *)taskCompletionSource;
@property (strong, nonatomic) NSURLSessionTask *connectionTask;

@end


@interface HackfoldrClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (HackfoldrTaskCompletionSource *)taskCompletionPagaDataAtPath:(NSString *)inPath;

- (BFTask *)pagaDataAtPath:(NSString *)inPath;

@property (nonatomic, strong) HackfoldrPage *lastPage;

@end
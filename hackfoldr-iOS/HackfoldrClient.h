//
//  HackfoldrClient.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "Bolts.h"

#define HackfoldrPageChangeIdNotification @"HackfoldrPageChangeIdNotification"

@class HackfoldrPage;

@interface HackfoldrClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void) setHackfoldrId:(NSString *)hfId;
- (BFTask *)getPageData;

@property (nonatomic, strong) HackfoldrPage *lastPage;
@property (nonatomic, strong, readonly) NSString *hfId;

@end
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

@interface HackfoldrClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (BFTask *)pagaDataAtPath:(NSString *)inPath;

@property (nonatomic, strong) HackfoldrPage *lastPage;

@end
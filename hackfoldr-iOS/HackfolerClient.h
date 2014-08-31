//
//  HackfolerClient.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "Bolts.h"

@class HackfolerPage;

@interface HackfolerClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (BFTask *)pagaDataAtPath:(NSString *)inPath;

@property (nonatomic, strong) HackfolerPage *lastPage;

@end
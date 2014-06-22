//
//  HackfolerClient.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "Bolts.h"
#import "HackfolerField.h"

@interface HackfolerClient : AFHTTPSessionManager <UITableViewDataSource>

+ (instancetype)sharedClient;

- (BFTask *)pagaDataAtPath:(NSString *)inPath;

// Objcect in NSArray is |HackfolerField|
- (NSArray *)fields;

@end
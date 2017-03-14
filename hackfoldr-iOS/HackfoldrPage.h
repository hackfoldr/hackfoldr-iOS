//
//  HackfoldrPage.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfoldrField.h"

@interface HackfoldrPage : NSObject <NSCopying>

- (instancetype)initWithKey:(NSString *)hackfoldrKey fieldArray:(NSArray *)fieldArray;

- (instancetype)initWithFieldArray:(NSArray *)fieldArray;

@property (nonatomic, strong, readonly) NSString *key;

@property (nonatomic, strong) NSString *pageTitle;

/// Objcect in NSArray is |HackfoldrField|
@property (nonatomic, strong, readonly) NSArray<HackfoldrField *> *cells;

/**
 * rediredKey is redired key from A1
 * This is Hackfoldr 2.0 rule
 */
@property (nonatomic, strong, readonly) NSString *rediredKey;

@end

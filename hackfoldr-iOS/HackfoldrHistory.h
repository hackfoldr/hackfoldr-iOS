//
//  HackfoldrHistory.h
//  hackfoldr-iOS
//
//  Created by 舒特比 on 2015/4/3.
//  Copyright (c) 2015年 org.superbil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HackfoldrHistory : NSManagedObject

@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) NSDate * refreshDate;
@property (nonatomic, strong) NSString * hackfoldrKey;
@property (nonatomic, strong) NSString * rediredKey;
@property (nonatomic, strong) NSString * title;

@end

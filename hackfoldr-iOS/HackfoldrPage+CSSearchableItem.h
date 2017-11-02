//
//  HackfoldrPage+CSSearchableItem.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2017/11/2.
//  Copyright © 2017年 org.g0v. All rights reserved.
//

#import "HackfoldrPage.h"
#import <CoreSpotlight/CoreSpotlight.h>

@interface HackfoldrPage (CSSearchableItem)

@property (nonatomic, readonly) CSSearchableItemAttributeSet *searchableAttributeSet;

- (CSSearchableItem *)searchableItemWithDomain:(NSString *)domain;

@end

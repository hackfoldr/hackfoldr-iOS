//
//  HackfoldrPage+CSSearchableItem.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2017/11/2.
//Copyright © 2017年 org.g0v. All rights reserved.
//

#import "HackfoldrPage+CSSearchableItem.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation HackfoldrPage (CSSearchableItemAttributeSet)

- (CSSearchableItemAttributeSet *)searchableAttributeSet {
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(__bridge NSString *)kUTTypeData];
    attributeSet.title = self.pageTitle;
    attributeSet.contentDescription = self.key;
    attributeSet.keywords = @[@"Hackfoldr", self.key];
    return attributeSet;
}

- (CSSearchableItem *)searchableItemWithDomain:(NSString *)domain {
    CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:self.key
                                                               domainIdentifier:domain
                                                                   attributeSet:self.searchableAttributeSet];
    return item;
}

@end

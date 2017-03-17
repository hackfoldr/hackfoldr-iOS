//
//  HackfoldrClient+Store.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2017/3/17.
//  Copyright © 2017年 org.g0v. All rights reserved.
//

#import "HackfoldrClient+Store.h"

#import <MagicalRecord/MagicalRecord.h>

#import "HackfoldrHistory.h"
#import "HackfoldrPage.h"

@implementation HackfoldrClient (Store)

- (HackfoldrTaskCompletionSource *)hackfoldrPageTaskWithKey:(NSString *)hackfoldrKey rediredKey:(NSString *)rediredKey
{
    NSString *key = hackfoldrKey;
    if (rediredKey) {
        key = rediredKey;
    }

    HackfoldrTaskCompletionSource *s = [[HackfoldrClient sharedClient] taskCompletionWithKey:key];
    [[s.task continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        HackfoldrPage *page = t.result;

        if (page.rediredKey) {
            NSLog(@"redired to:%@", page.rediredKey);
            return [self hackfoldrPageTaskWithKey:page.key rediredKey:page.rediredKey].task;
        }

        NSLog(@"page: %@", page);
        return t;
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        HackfoldrPage *page = t.result;

        // Save |history| to core data
        HackfoldrHistory *history = [HackfoldrHistory MR_findFirstByAttribute:@"hackfoldrKey" withValue:page.key];
        if (!history) {
            history = [HackfoldrHistory MR_createEntity];
            history.createDate = [NSDate date];
            history.refreshDate = [NSDate date];
            history.hackfoldrKey = page.key;
            history.title = page.pageTitle;
            if (page.rediredKey) {
                history.rediredKey = page.rediredKey;
            }
        } else {
            history.refreshDate = [NSDate date];
            history.title = page.pageTitle;
            if (page.rediredKey) {
                history.rediredKey = page.rediredKey;
            }
        }

        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:nil];
        return t;
    }];
    return s;
}

@end

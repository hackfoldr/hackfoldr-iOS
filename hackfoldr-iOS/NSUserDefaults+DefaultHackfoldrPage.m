//
//  NSUserDefaults+DefaultHackfoldrPage.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2015/1/28.
//  Copyright (c) 2015年 superbil.org All rights reserved.
//

#import "NSUserDefaults+DefaultHackfoldrPage.h"

static NSString *kDefaultHackfoldrPage = @"Default Hackfoldr Page";
static NSString *kCurrentHackfoldrPage = @"Current Hackfoldr Page";

@implementation NSUserDefaults (DefaultHackfoldrPage)

- (NSString *)stringOfDefaultHackfoldrPage
{
    return [self objectForKey:kDefaultHackfoldrPage];
}

- (void)setDefaultHackfoldrPage:(NSString *)aString
{
    [self setObject:aString forKey:kDefaultHackfoldrPage];
}

- (void)removeDefaultHackfolderPage
{
    [self removeObjectForKey:kDefaultHackfoldrPage];
}

@end

@implementation NSUserDefaults (CurrentHackfoldrPage)

- (NSString *)stringOfCurrentHackfoldrPage
{
    NSString *current = [self objectForKey:kCurrentHackfoldrPage];
    if (current && current.length > 0) {
        return current;
    }
    // When |currentHackfoldrPage| can't find, use defualt
    return [self stringOfDefaultHackfoldrPage];
}

- (void)setCurrentHackfoldrPage:(NSString *)anString
{
    [self setObject:anString forKey:kCurrentHackfoldrPage];
}

- (void)removeCurrentHackfoldrPage
{
    [self removeObjectForKey:kCurrentHackfoldrPage];
}

@end

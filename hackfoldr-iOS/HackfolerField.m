//
//  HackfolerField.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfolerField.h"

@implementation HackfolerField

- (BOOL)isEmpty
{
    if (!self.urlString && !self.name && !self.actions) {
        return YES;
    }

    if (self.urlString.length == 0 && self.name.length == 0 && self.actions.length == 0) {
        return YES;
    }

    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"index:%ld name:%@ url:%@ actions:%@", (long)self.index, self.name, self.urlString, self.actions];
}

@end

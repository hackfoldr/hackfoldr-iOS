//
//  NSURL+Hackfoldr.m
//  hackfoldr-iOS
//
//  Created by 舒特比 on 2016/12/17.
//  Copyright © 2016年 org.g0v. All rights reserved.
//

#import "NSURL+Hackfoldr.h"

@implementation NSURL (Hackfoldr)

+ (BOOL)canHandleHackfoldrURL:(nonnull NSURL *)url
{
    if ([url.scheme isEqualToString:@"hackfoldr"]) {
        return YES;
    }
    return NO;
}

@end

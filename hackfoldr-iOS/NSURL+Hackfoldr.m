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
    } else if ([url.host isEqualToString:@"hackfoldr.org"]) {
        if ([url.path isEqualToString:@"/about"]) {
            return NO;
        }
        return YES;
    } else if ([url.host isEqualToString:@"beta.hackfoldr.org"]) {
        return YES;
    }
    return NO;
}

+ (nullable NSString *)realKeyOfHackfoldrWithURL:(nonnull NSURL *)url
{
    if ([url.scheme isEqualToString:@"hackfoldr"]) {
        return url.host;
    } else if ([url.host isEqualToString:@"hackfoldr.org"] || [url.host isEqualToString:@"beta.hackfoldr.org"]) {
        return [url.path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    }
    return nil;
}

+ (NSString *)validatorHackfoldrKey:(NSString *)hackfoldrKey
{
    NSString *newHackfoldrKey = [hackfoldrKey copy];
    // Find hackfoldr page key
    if ([newHackfoldrKey rangeOfString:@"://"].location != NSNotFound) {
        NSURL *hackfoldrURL = [NSURL URLWithString:newHackfoldrKey];
        if ([NSURL canHandleHackfoldrURL:hackfoldrURL]) {
            newHackfoldrKey = [NSURL realKeyOfHackfoldrWithURL:hackfoldrURL];
        }
    }

    // Remove white space and new line
    newHackfoldrKey = [newHackfoldrKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // Use escapes to encoding |newHackfoldrPage|
    newHackfoldrKey = [newHackfoldrKey stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    return newHackfoldrKey;
}

@end

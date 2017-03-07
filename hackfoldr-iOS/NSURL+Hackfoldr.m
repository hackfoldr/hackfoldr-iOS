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
        return YES;
    } else if ([url.host isEqualToString:@"beta.hackfoldr.org"]) {
        return YES;
    }
    return NO;
}

+ (NSString *)validatorHackfoldrKey:(NSString *)newHackfoldrKey {
    // Find hackfoldr page key, if prefix is http or https
    if ([newHackfoldrKey hasPrefix:@"http"]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*hackfoldr.org/(.*)/"
                                                                               options:NSRegularExpressionAllowCommentsAndWhitespace
                                                                                 error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:newHackfoldrKey
                                                        options:NSMatchingReportCompletion
                                                          range:NSMakeRange(0, newHackfoldrKey.length)];
        if (match.range.location != NSNotFound) {
            newHackfoldrKey = [newHackfoldrKey substringWithRange:[match rangeAtIndex:1]];
        }
    }

    // Remove white space and new line
    newHackfoldrKey = [newHackfoldrKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // Use escapes to encoding |newHackfoldrPage|
    newHackfoldrKey = [newHackfoldrKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    return newHackfoldrKey;
}

@end

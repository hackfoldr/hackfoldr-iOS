//
//  NSURL+Hackfoldr.h
//  hackfoldr-iOS
//
//  Created by 舒特比 on 2016/12/17.
//  Copyright © 2016年 org.g0v. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Hackfoldr)

+ (BOOL)canHandleHackfoldrURL:(nonnull NSURL *)url;

+ (nonnull NSString *)validatorHackfoldrKey:(nonnull NSString *)newHackfoldrKey;

@end

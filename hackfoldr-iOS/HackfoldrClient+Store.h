//
//  HackfoldrClient+Store.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2017/3/17.
//  Copyright © 2017年 org.g0v. All rights reserved.
//

#import "HackfoldrClient.h"

@interface HackfoldrClient (Store)

- (HackfoldrTaskCompletionSource *)hackfoldrPageTaskWithKey:(NSString *)hackfoldrKey rediredKey:(NSString *)rediredKey;

@end

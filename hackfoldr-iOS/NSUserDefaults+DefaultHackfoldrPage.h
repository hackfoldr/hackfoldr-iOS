//
//  NSUserDefaults+DefaultHackfoldrPage.h
//  hackfoldr-iOS
//
//  Created by 舒特比 on 2015/1/28.
//  Copyright (c) 2015年 superbil.org All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (DefaultHackfoldrPage)

- (NSString *)stringOfDefaultHackfoldrPage;

- (void)setDefaultHackfoldrPage:(NSString *)aString;

- (void)removeDefaultHackfolderPage;

@end

@interface NSUserDefaults (CurrentHackfoldrPage)

- (NSString *)stringOfCurrentHackfoldrPage;

- (void)setCurrentHackfoldrPage:(NSString *)anString;

- (void)removeCurrentHackfoldrPage;

- (NSString *)hackfoldrPageKey;

@end

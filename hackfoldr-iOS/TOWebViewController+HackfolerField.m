//
//  TOWebViewController+HackfolerField.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/25.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "TOWebViewController+HackfolerField.h"

#import "HackfolerField.h"

@implementation TOWebViewController (HackfolerField)

- (void)loadWithField:(HackfolerField *)oneField
{
    self.url = [NSURL URLWithString:oneField.urlString];
}

@end

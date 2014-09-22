//
//  TOWebViewController+HackfoldrField.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/25.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "TOWebViewController+HackfoldrField.h"

#import "HackfoldrField.h"

@implementation TOWebViewController (HackfoldrField)

- (void)loadWithField:(HackfoldrField *)oneField
{
    self.url = [NSURL URLWithString:oneField.urlString];
}

@end

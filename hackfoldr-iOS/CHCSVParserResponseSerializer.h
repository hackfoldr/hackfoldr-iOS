//
//  CHCSVParserResponseSerializer.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "AFURLResponseSerialization.h"

/**
 `CHCSVParserResponseSerializer` is a subclass of `AFHTTPResponseSerializer` that validates and decodes XML responses as an `NSArray`, which includes `HackfolerField`.

 By default, `CHCSVParserResponseSerializer` accepts the following MIME types, which includes the official standard, `text/csv`, as well as other commonly-used types:

 - `text/csv`
 */

@interface CHCSVParserResponseSerializer : AFHTTPResponseSerializer

/*
 CHCSVParser settings
 */
@property (assign) BOOL recognizesBackslashesAsEscapes; // default is NO
@property (assign) BOOL sanitizesFields; // default is NO
@property (assign) BOOL recognizesComments; // default is NO

@end

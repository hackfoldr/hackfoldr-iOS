//
//  AFCSVParserResponseSerializer.h
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "AFURLResponseSerialization.h"

/**
 `AFCSVParserResponseSerializer` is a subclass of `AFHTTPResponseSerializer` that validates and decodes CSV responses as an `NSArray`,

 By default, `AFCSVParserResponseSerializer` accepts the following MIME types:

 - `text/csv`
 */

@interface AFCSVParserResponseSerializer : AFHTTPResponseSerializer

/*
 CHCSVParser settings
 */
@property (assign) BOOL recognizesBackslashesAsEscapes; // default is NO
@property (assign) BOOL sanitizesFields; // default is NO
@property (assign) BOOL recognizesComments; // default is NO
@property (assign) NSStringEncoding usedEncoding;
@property (assign) unichar usedDelimiter;

@end

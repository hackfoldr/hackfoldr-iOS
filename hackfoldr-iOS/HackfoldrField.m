//
//  HackfoldrField.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfoldrField.h"

typedef NS_ENUM(NSUInteger, FieldType) {
    FieldType_URLString = 0,
    FieldType_Name,
    FieldType_Actions,
    FieldType_Tag,
    FieldType_Live
};

@interface HackfoldrField () {
    NSString *_urlString;
}
@end

@implementation HackfoldrField

- (instancetype)initWithFieldArray:(NSArray *)fields
{
    self = [super init];
    if (!self) {
        return nil;
    }

    if (!fields) {
        return self;
    }

    [fields enumerateObjectsUsingBlock:^(NSString *field, NSUInteger idx, BOOL *stop) {
        switch (idx) {
            case FieldType_URLString:
                self.urlString = field;
                break;
            case FieldType_Name:
                self.name = field;
                break;
            case FieldType_Actions:
                self.actions = field;
                break;
            case FieldType_Tag:
                self.tag = field;
                break;
            case FieldType_Live:
                self.live = field;
                break;
                
            default:
                break;
        }
    }];

    return self;
}

- (BOOL)isEmpty
{
    if (!self.urlString && !self.name && !self.actions) {
        return YES;
    }

    if (self.urlString.length == 0 && self.name.length == 0 && self.actions.length == 0) {
        return YES;
    }

    return NO;
}

- (void)setUrlString:(NSString *)aURLString
{
    NSString *cleanString = [aURLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _urlString = cleanString;

    if (!aURLString || aURLString.length == 0) {
        return;
    }

    // While first string is space, this HackfoldrField is subItem
    self.isSubItem = [[aURLString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "];
}

- (NSString *)urlString
{
    return _urlString;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];

    [description appendFormat:@"index:%ld ", (long)self.index];
    if (self.name) {
        [description appendFormat:@"name: %@ ", self.name];
    }
    if (self.urlString) {
        [description appendFormat:@"urlString: %@ ", self.urlString];
    }
    if (self.actions) {
        [description appendFormat:@"actions: %@ ", self.actions];
    }

    [description appendFormat:@"isSubItem: %@", self.actions ? @"YES" : @"NO"];

    return description;
}

@end

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
};

@interface HackfoldrField () {
    NSString *_urlString;
}
@end

@implementation HackfoldrField

- (instancetype)init {
    if (self = [super init]) {
        _subFields = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithFieldArray:(NSArray *)fields
{
    self = [self init];
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
            default:
                break;
        }
    }];

    return self;
}

#pragma mark - Setter and Getter

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
    NSString *cleanString = [aURLString stringByReplacingOccurrencesOfString:@" " withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    _urlString = cleanString;

    [self setIsSubItemWithURLString:aURLString];
}

- (NSString *)urlString
{
    return _urlString;
}

- (void)setIsSubItemWithURLString:(NSString *)aURLString
{
    if (!aURLString || aURLString.length == 0) {
        return;
    }

    // While first string is space, this HackfoldrField is subItem
    [aURLString enumerateSubstringsInRange:NSMakeRange(0, aURLString.length)
                                   options:NSStringEnumerationByComposedCharacterSequences
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
    {
        if ([substring isEqualToString:@" "]) {
            self.isSubItem = YES;
            *stop = YES;
        }
    }];
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

    [description appendFormat:@"isSubItem: %@ ", self.isSubItem ? @"YES" : @"NO"];

    if (self.subFields.count > 0) {
        [description appendFormat:@"subFields: %@ ", self.subFields];
    }

    return description;
}

@end

//
//  HackfoldrField.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfoldrField.h"

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

typedef NS_ENUM(NSUInteger, FieldType) {
    FieldType_URL = 0,
    FieldType_Title,
    FieldType_Foldrexpand,
    FieldType_Label
};

@interface HackfoldrField () {
    NSString *_urlString;
    NSString *_labelString;
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
            case FieldType_URL:
                self.urlString = field;
                break;
            case FieldType_Title:
                self.name = field;
                break;
            case FieldType_Foldrexpand:
                self.actions = field;
                break;
            case FieldType_Label:
                self.labelString = field;
                break;
            default:
                break;
        }
    }];
    // hackfoldr 2.0 rule
    self.isCommentLine = [self isCommentLineWithFieldArray:fields];

    return self;
}

- (BOOL)isCommentLineWithFieldArray:(NSArray *)fields
{
    __block BOOL isCommentLine = NO;
    [fields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *field = [obj stringByReplacingOccurrencesOfString:@"\"" withString:@""];;
            // only read first one
            if ([field hasPrefix:@"#"]) {
                isCommentLine = YES;
                *stop = YES;
            }
        }
    }];
    return isCommentLine;
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
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    _urlString = cleanString;

    [self setIsSubItemWithURLString:aURLString];
}

- (NSString *)urlString
{
    return _urlString;
}

- (void)setIsSubItemWithURLString:(NSString *)aURLString
{
    // |aURLString| must have '://', otherwise that is not subItem
    if (!aURLString ||
        aURLString.length == 0 ||
        [aURLString rangeOfString:@"://"].location == NSNotFound) {
        return;
    }

    // hackfoldr 2.0 rule, default is subItem
    self.isSubItem = YES;
    // While first string is space, this HackfoldrField is subItem
    if ([aURLString hasPrefix:@" "]) {
        self.isSubItem = YES;
    }
    if ([aURLString hasPrefix:@"<"]) {
        self.isSubItem = NO;
    }
}

- (void)setLabelString:(NSString *)labelString
{
    if (labelString.length == 0) {
        _labelString = labelString;
        return;
    }

    __block NSString *colorName = nil;
    [[self colorTable] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, UIColor * _Nonnull c, BOOL * _Nonnull stop) {
        if ([labelString rangeOfString:name].location != NSNotFound) {
            colorName = name;
            *stop = YES;
        }
    }];
    if (colorName && [self updateLabelColorByString:colorName]) {
        NSString *cleanLabel = [labelString stringByReplacingOccurrencesOfString:colorName withString:@""];
        cleanLabel = [cleanLabel stringByReplacingOccurrencesOfString:@"important" withString:@""];
        cleanLabel = [cleanLabel stringByReplacingOccurrencesOfString:@"warning" withString:@""];
        cleanLabel = [cleanLabel stringByReplacingOccurrencesOfString:@"issue" withString:@""];
        cleanLabel = [cleanLabel stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        cleanLabel = [cleanLabel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _labelString = cleanLabel;
        return;
    }

    _labelString = labelString;
}

- (NSString *)labelString
{
    return _labelString;
}

- (NSDictionary<NSString *, UIColor *> *)colorTable {
    UIColor *defaultColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35f];
    return @{@"black" : UIColorFromRGB(0x5C6166),
             @"blue" : UIColorFromRGB(0x6ECFF5),
             @"deep-blue" : UIColorFromRGB(0x006DCC),
             @"deep-green" : UIColorFromRGB(0x5BB75B),
             @"deep-purple" : UIColorFromRGB(0x564F8A),
             @"gray" : defaultColor,
             @"green" : UIColorFromRGB(0xA1CF64),
             @"important" : UIColorFromRGB(0xD95C5C),
             @"issue" : defaultColor,
             @"orange" : UIColorFromRGB(0xF0AD4E),
             @"pink" : UIColorFromRGB(0xF3A8AA),
             @"purple" : UIColorFromRGB(0x9B96F7),
             @"red" : UIColorFromRGB(0xD95C5C),
             @"teal" : UIColorFromRGB(0x00B5AD),
             @"warning" : UIColorFromRGB(0xF0AD4E),
             @"yellow" : UIColorFromRGB(0xF0AD4E),
             };
}

- (BOOL)updateLabelColorByString:(NSString *)colorString
{
    self.labelColor = [self colorTable][colorString];
    if (self.labelColor) {
        return YES;
    }

    self.labelColor = [self colorTable][@"gray"];
    return NO;
}

#pragma mark - DEBUG

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
    [description appendFormat:@"isCommentLine: %@ ", self.isCommentLine ? @"YES" : @"NO"];

    if (self.subFields.count > 0) {
        [description appendString:@"subFields: {\n"];
        for (HackfoldrField *sf in self.subFields) {
            [description appendFormat:@"\t%@\n", sf.description];
        }
        [description appendString:@"}\n"];
    }

    if (self.labelString) {
        [description appendFormat:@"labelString: %@ ", self.labelString];
    }

    if (self.labelColor) {
        [description appendFormat:@"labelColor: %@ ", self.labelColor];
    }

    return description;
}

@end

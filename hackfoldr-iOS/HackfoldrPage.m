//
//  HackfoldrPage.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfoldrPage.h"

#import "HackfoldrField.h"

@interface HackfoldrPage ()
@property (nonatomic, strong, readwrite) NSString *key;
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong, readwrite) NSString *pagetitle;
@property (nonatomic, strong, readwrite) NSString *rediredKey;
@end

@implementation HackfoldrPage

- (instancetype)initWithFieldArray:(NSArray *)fieldArray
{
    return [self initWithKey:nil fieldArray:fieldArray];
}

- (instancetype)initWithKey:(NSString *)hackfoldrKey fieldArray:(NSArray *)fieldArray
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.key = hackfoldrKey;

    [self updateWithArray:fieldArray];

    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    HackfoldrPage *copy = [[HackfoldrPage allocWithZone:zone] init];
    copy.key = [self.key copy];
    copy.fields = [self.fields copy];
    copy.pageTitle = [self.pageTitle copy];
    copy.rediredKey = [self.rediredKey copy];
    return copy;
}

- (NSArray *)cells
{
    return self.fields;
}

- (void)updateWithArray:(NSArray *)fieldArray
{
    if (!fieldArray || fieldArray.count == 0) {
        return;
    }

    // Check this page is redired page
    NSString *a1String = ((NSArray *)fieldArray.firstObject).firstObject;
    a1String = [a1String stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    // Check A1 is not comment field and length >= 40
    if ([a1String hasPrefix:@"#"] == NO && a1String.length >= 40) {
        self.rediredKey = a1String;
        // because this is redired page, ignore other things
        return;
    }

    NSMutableArray *sectionFields = [NSMutableArray array];
    __block HackfoldrField *sectionField = nil;
    __block BOOL isFindTitle = NO;
    [fieldArray enumerateObjectsUsingBlock:^(NSArray *fields, NSUInteger idx, BOOL *stop) {
        HackfoldrField *field = [[HackfoldrField alloc] initWithFieldArray:fields];

        if (field.isEmpty || field.isCommentLine) {
            return;
        }
        field.index = idx;

        // find first row isn't comment line and not empty
        if (!isFindTitle) {
            self.pageTitle = field.name;
            isFindTitle = YES;
            return;
        }

        // other row
        if (field.isSubItem == NO) {
            // add last |sectionField|
            if (sectionField) {
                [sectionFields addObject:sectionField];
            }

            // Create new section field
            // When field have |urlString|, just put into a new section
            if (field.urlString.length == 0) {
                sectionField = field;
            } else {
                sectionField = [[HackfoldrField alloc] init];
                [sectionField.subFields addObject:field];
            }
        } else {
            // section could be nil
            if (!sectionField) {
                sectionField = [[HackfoldrField alloc] init];
            }
            // add |field| to subFields
            [sectionField.subFields addObject:field];
        }
    }];
    // Check every section is been add or not
    if (sectionField) {
        [sectionFields addObject:sectionField];
    }

    self.fields = sectionFields;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"key: %@\n", self.key];
    [description appendFormat:@"pageTitle: %@\n", self.pageTitle];
    if (self.rediredKey) {
        [description appendFormat:@"rediredKey: %@", self.rediredKey];
    }
//    [description appendFormat:@"cells: %@", self.fields];
    return description;
}

@end

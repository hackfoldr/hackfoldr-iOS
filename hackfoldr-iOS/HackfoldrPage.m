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
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong, readwrite) NSString *pagetitle;
@end

@implementation HackfoldrPage

- (instancetype)initWithFieldArray:(NSArray *)fieldArray
{
    self = [super init];
    if (!self) {
        return nil;
    }

    [self updateWithArray:fieldArray];

    return self;
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

    NSMutableArray *sectionFields = [NSMutableArray array];
    __block HackfoldrField *sectionField = nil;
    __block BOOL isFindTitle = NO;
    [fieldArray enumerateObjectsUsingBlock:^(NSArray *fields, NSUInteger idx, BOOL *stop) {
        HackfoldrField *field = [[HackfoldrField alloc] initWithFieldArray:fields];

        if (field.isEmpty || field.isCommentLine) {
            return;
        }

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
    [description appendFormat:@"pageTitle: %@\n", self.pageTitle];
    [description appendFormat:@"cells: %@", self.fields];
    return description;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fields.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    HackfoldrField *sectionField = self.fields[section];
    return sectionField.subFields.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    HackfoldrField *sectionFeild = self.fields[section];
    return sectionFeild.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSStringFromClass([self class]) stringByAppendingString:@"Cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    HackfoldrField *sectionField = self.fields[indexPath.section];
    HackfoldrField *field = sectionField.subFields[indexPath.row];
    cell.textLabel.text = field.name;

    return cell;
}

@end

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
@property (nonatomic, strong, readwrite) NSString *rediredKey;
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

- (instancetype)copyWithZone:(NSZone *)zone
{
    HackfoldrPage *copy = [[HackfoldrPage allocWithZone:zone] init];
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
    [description appendFormat:@"pageTitle: %@\n", self.pageTitle];
    if (self.rediredKey) {
        [description appendFormat:@"rediredKey: %@", self.rediredKey];
    }
//    [description appendFormat:@"cells: %@", self.fields];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    HackfoldrField *sectionField = self.fields[indexPath.section];
    HackfoldrField *field = sectionField.subFields[indexPath.row];
    cell.textLabel.text = field.name;

    cell.accessoryType = field.urlString.length > 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;

    // Default color is white
    cell.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    // Only setup when |field.labelString| have value
    if (field.labelString.length > 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@" %@ ", field.labelString];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.backgroundColor = field.labelColor;
        [cell.detailTextLabel.layer setCornerRadius:3.f];
        [cell.detailTextLabel.layer setMasksToBounds:YES];
    }
    NSLog(@"field:%@",field);

    return cell;
}

@end

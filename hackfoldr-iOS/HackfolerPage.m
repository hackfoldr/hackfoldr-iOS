//
//  HackfolerPage.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfolerPage.h"

#import "HackfolerField.h"

@interface HackfolerPage ()
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong, readwrite) NSString *pagetitle;
@end

@implementation HackfolerPage

- (instancetype)initWithFieldArray:(NSArray *)fieldArray
{
    self = [super init];
    if (!self) {
        return nil;
    }

    [self findTitleWithArray:fieldArray];

    return self;
}

- (NSArray *)cells
{
    return self.fields;
}

- (void)findTitleWithArray:(NSArray *)fieldArray
{
    if (!fieldArray || fieldArray.count == 0) {
        return;
    }

    NSMutableArray *cellsWithoutTitleField = [NSMutableArray array];

    [fieldArray enumerateObjectsUsingBlock:^(NSArray *fields, NSUInteger idx, BOOL *stop) {
        HackfolerField *field = [[HackfolerField alloc] initWithFieldArray:fields];
        // first row is title row
        if (idx == 0) {
            self.pageTitle = field.name;
            return;
        }
        // other row
        if (!field.isEmpty) {
            [cellsWithoutTitleField addObject:field];
        }
    }];

    self.fields = cellsWithoutTitleField;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"pageTitle: %@\n", self.pageTitle];
    [description appendFormat:@"cells: %@", self.fields];
    return description;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];

    cell.textLabel.text = ((HackfolerField *)self.fields[indexPath.row]).name;

    return cell;
}

@end

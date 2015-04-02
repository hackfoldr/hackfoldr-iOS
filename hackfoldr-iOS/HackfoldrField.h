//
//  HackfoldrField.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

@interface HackfoldrField : NSObject

- (instancetype)initWithFieldArray:(NSArray *)fields;

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *actions;
@property (nonatomic, copy) NSString *labelString;

@property (nonatomic, assign) BOOL isSubItem;
@property (nonatomic, assign) BOOL isCommentLine;

@property (nonatomic, strong) NSMutableArray *subFields;

- (BOOL)isEmpty;

@end

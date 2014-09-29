//
//  ListViewController.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/8/31.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//
#import "HackfoldrField.h"

@protocol LeftViewControllerDelegate <NSObject>
@optional
- (void) loadWithField:(HackfoldrField *)field;
@end

@interface ListViewController : UITableViewController
@property (weak, nonatomic) id <LeftViewControllerDelegate> delegate;
@end

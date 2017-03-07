//
//  ListFieldViewController.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/8/31.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

@class BFTask;
@class HackfoldrPage;
@class HackfoldrTaskCompletionSource;

@interface ListFieldViewController : UITableViewController

+ (instancetype)viewController;

@property (nonatomic, strong) IBOutlet UIButton *settingButton;

@property (nonatomic, assign) BOOL hideBackButton;

@property (nonatomic, strong) HackfoldrPage *currentPage;

- (HackfoldrTaskCompletionSource *)updateHackfoldrPageTaskWithKey:(NSString *)hackfoldrKey rediredKey:(NSString *)rediredKey;

- (void)updateHackfoldrPageWithKey:(NSString *)hackfoldrKey;

- (void)showSettingViewController;

@end

//
//  ListFieldViewController.h
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/8/31.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

@class BFTask;
@class RATreeView;
@class HackfoldrPage;
@class HackfoldrTaskCompletionSource;

NS_ASSUME_NONNULL_BEGIN

@interface ListFieldViewController : UIViewController

+ (instancetype)viewController;

@property (nonatomic, strong) RATreeView *treeView;

@property (nonatomic, strong) IBOutlet UIButton *settingButton;

@property (nonatomic, assign) BOOL hideBackButton;

@property (nonatomic, strong) HackfoldrPage *page;

- (void)reloadPage;

- (HackfoldrTaskCompletionSource *)updateHackfoldrPageTaskWithKey:(NSString *)hackfoldrKey rediredKey:(nullable NSString *)rediredKey;

- (void)updateHackfoldrPageWithKey:(NSString *)hackfoldrKey;

- (void)showSettingViewController;

@end

NS_ASSUME_NONNULL_END

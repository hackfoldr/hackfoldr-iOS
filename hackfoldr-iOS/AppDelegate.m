//
//  AppDelegate.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/21.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "AppDelegate.h"

#import <CoreSpotlight/CoreSpotlight.h>
#import <MagicalRecord/MagicalRecord.h>

#import "MainViewController.h"
#import "NSURL+Hackfoldr.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // setup core data
    [MagicalRecord setupCoreDataStack];

    self.viewController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc] init]];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app handleOpenURL:(nonnull NSURL *)url
{
    return [NSURL canHandleHackfoldrURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    NSLog(@"openURL: %@ options: %@", url, options);
    return [self tryUpdateHackfoldrPageKeyWithURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    return [self tryUpdateHackfoldrPageKeyWithURL:url];
}

- (void)updateCurrentHackfoldrPageWithKey:(NSString *)pageKey {
    if (!pageKey || pageKey.length == 0) return;

    // Find MainViewController
    __block MainViewController *vc = nil;
    [((UINavigationController *)self.viewController).viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MainViewController class]]) {
            vc = obj;
            *stop = YES;
        }
    }];
    if (!vc) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [vc updateHackfoldrPageWithKey:pageKey];
    });
}

- (BOOL)tryUpdateHackfoldrPageKeyWithURL:(NSURL *)url {
    BOOL canHandle = [NSURL canHandleHackfoldrURL:url];
    [self updateCurrentHackfoldrPageWithKey:url.host];
    return canHandle;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
        NSLog(@"CSSearchableItemActionType");
        NSString *uniqueIdentifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
        NSLog(@"uniqueIdentifier %@", uniqueIdentifier);
        [self updateCurrentHackfoldrPageWithKey:uniqueIdentifier];
    }
    return YES;
}

@end

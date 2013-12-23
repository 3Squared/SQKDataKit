//
//  SQKAppDelegate.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKAppDelegate.h"
#import "SQKCommitsViewController.h"
#import "SQKContextManager.h"
#import "SQKMetricsViewController.h"

@interface SQKAppDelegate ()
@property (nonatomic, readwrite, strong) SQKContextManager *contextManager;
@end

@implementation SQKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    SQKCommitsViewController *commitsViewController = [[SQKCommitsViewController alloc] init];
    commitsViewController.contextManager = self.contextManager;
    UINavigationController *commitsNavController = [[UINavigationController alloc] initWithRootViewController:commitsViewController];
    
    SQKMetricsViewController *metricsViewController = [[SQKMetricsViewController alloc] init];
    metricsViewController.contextManager = self.contextManager;
    UINavigationController *metricsNavController = [[UINavigationController alloc] initWithRootViewController:metricsViewController];
    
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[metricsNavController, commitsNavController];
    
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (SQKContextManager *)contextManager {
    if (!_contextManager) {
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        _contextManager = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType managedObjectModel:model];
    }
    return _contextManager;
}

@end

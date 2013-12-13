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

    SQKCommitsViewController *commitsViewController = [[SQKCommitsViewController alloc] initWithStyle:UITableViewStylePlain];
    commitsViewController.title = @"List";
    UINavigationController *commitsNavController = [[UINavigationController alloc] initWithRootViewController:commitsViewController];
    
    SQKMetricsViewController *matricsViewController = [[SQKMetricsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    matricsViewController.title = @"Metrics";
    UINavigationController *metricsNavController = [[UINavigationController alloc] initWithRootViewController:matricsViewController];
    
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[metricsNavController, commitsNavController];
    
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

+ (SQKAppDelegate *)appDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (SQKContextManager *)contextManager {
    if (!_contextManager) {
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        _contextManager = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType managedObjectModel:model];
    }
    return _contextManager;
}

@end

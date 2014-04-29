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

// Helper function to see if we are running the production target or the test target
static BOOL isRunningTests(void) __attribute__((const));
static BOOL isRunningTests(void) {
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"octest"] || [[injectBundle pathExtension] isEqualToString:@"xctest"];
}

@implementation SQKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (isRunningTests()) {
        return YES;
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    SQKCommitsViewController *commitsViewController = [[SQKCommitsViewController alloc] initWithContext:self.contextManager.mainContext];
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

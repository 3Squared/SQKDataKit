//
//  CDOAppDelegate.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 27/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "CDOAppDelegate.h"
#import "CDOGithubAPIClient.h"
#import "CDODataSychroniser.h"
#import "SQKContextManager.h"
#import "CDORunningTestsHelper.h"

@interface CDOAppDelegate ()
@property (nonatomic, strong) CDODataSychroniser *dataSynchroniser;
@property (nonatomic, strong) SQKContextManager *contextManager;
@end

@implementation CDOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	if (isRunningTests()) return YES;

	// Set your Github API access token for the CDOGithubAPIClient
	// See: https://github.com/settings/applications#personal-access-tokens
	// I'm loading mine from a .plist (ignored in the git repo)
	NSString *path = [[NSBundle mainBundle] pathForResource:@"GithubToken" ofType:@"plist"];
	NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *accessToken = plistDict[@"token"];
	[CDOGithubAPIClient sharedInstance].accessToken = accessToken;

	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
	                                                managedObjectModel:model
	                                                          storeURL:nil];

	self.dataSynchroniser = [[CDODataSychroniser alloc] initWithContextManager:self.contextManager];
	[self.dataSynchroniser synchronise];

	return YES;
}

@end

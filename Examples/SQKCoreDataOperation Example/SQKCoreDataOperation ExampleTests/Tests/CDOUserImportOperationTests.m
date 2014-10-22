//
//  CDOUserImportOperationTests.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQKContextManager.h"
#import "NSManagedObject+SQKAdditions.h"
#import "CDOUserImportOperation.h"
#import "User.h"
#import <AGAsyncTestHelper/AGAsyncTestHelper.h>
#import "CDOGithubAPIClient.h"

@interface CDOUserImportOperationTests : XCTestCase
@property (nonatomic, strong) SQKContextManager *contextManager;
@property (nonatomic, strong) CDOUserImportOperation *operation;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation CDOUserImportOperationTests

- (void)setUp {
	[super setUp];

	// Set your Github API access token for the CDOGithubAPIClient
	// See: https://github.com/settings/applications#personal-access-tokens
	// I'm loading mine from a .plist (ignored in the git repo)
	NSString *path = [[NSBundle mainBundle] pathForResource:@"GithubToken" ofType:@"plist"];
	NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *accessToken = plistDict[@"token"];
	CDOGithubAPIClient *APIClient = [[CDOGithubAPIClient alloc] initWithAccessToken:accessToken];

	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
	                                                managedObjectModel:model
	                                                          storeURL:nil];
	self.operation = [[CDOUserImportOperation alloc] initWithContextManager:self.contextManager APIClient:APIClient];
	self.queue = [NSOperationQueue new];
}

- (void)testOperation {
	__block BOOL operationFinished = NO;
    
    NSManagedObjectContext *context = [self.contextManager mainContext];

    User *luke = [User sqk_insertInContext:context];
    luke.username = @"lukestringer90";
    
    User *blork = [User sqk_insertInContext:context];
    blork.username = @"blork";
    
    [context save:NULL];

	[self.operation setCompletionBlock: ^{
	    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{

	        NSFetchRequest *userFetchRequest = [User sqk_fetchRequest];
            
            // The operation should have filled in the missing properties for each user
	        userFetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", @"lukestringer90"];
	        User *user1 = (User *)[[context executeFetchRequest:userFetchRequest error:NULL] firstObject];
	        XCTAssertEqualObjects(user1.email, @"lukestringer90@gmail.com", @"");

	        userFetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", @"blork"];
	        User *user2 = (User *)[[context executeFetchRequest:userFetchRequest error:NULL] firstObject];
	        XCTAssertEqualObjects(user2.email, @"sam@blork.co.uk", @"");
		}];

	    operationFinished = YES;
	}];

	[self.queue addOperation:self.operation];
	AGWW_WAIT_WHILE(!operationFinished, 5.0);
}

@end

//
//  CDOCommitImportOperationTests.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQKContextManager.h"
#import "NSManagedObject+SQKAdditions.h"
#import "CDOCommitImportOperation.h"
#import "Commit.h"
#import <AGAsyncTestHelper/AGAsyncTestHelper.h>
#import "CDOGithubAPIClient.h"
#import <OCMock/OCMock.h>
#import "CDOJSONFixtureLoader.h"

@interface CDOCommitImportOperationTests : XCTestCase
@property (nonatomic, strong) SQKContextManager *contextManager;
@property (nonatomic, strong) CDOCommitImportOperation *operation;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation CDOCommitImportOperationTests

- (void)setUp {
	[super setUp];
    
    CDOGithubAPIClient *APIClientMock = OCMClassMock([CDOGithubAPIClient class]);
    
    NSArray *commitsJSON = [CDOJSONFixtureLoader loadJSONFileNamed:@"commits"];
    
    OCMStub([APIClientMock getCommitsForRepo:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(commitsJSON);
    
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
	                                                managedObjectModel:model
                                        orderedManagedObjectModelNames:@[@"SQKCoreDataOperation_Example"]
	                                                          storeURL:nil];
	self.operation = [[CDOCommitImportOperation alloc] initWithContextManager:self.contextManager APIClient:APIClientMock];
	self.queue = [NSOperationQueue new];
}

- (void)testOperation {
	__block BOOL operationFinished = NO;

	[self.operation setCompletionBlock: ^{
	    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
	        NSArray *commits = [[self.contextManager mainContext] executeFetchRequest:[Commit sqk_fetchRequest] error:NULL];
	        XCTAssertTrue(commits.count > 0, @"");
		}];

	    operationFinished = YES;
	}];

	[self.queue addOperation:self.operation];
	AGWW_WAIT_WHILE(!operationFinished, 5.0);
}

@end

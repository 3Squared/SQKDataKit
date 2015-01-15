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
#import <OCMock/OCMock.h>
#import "CDOJSONFixtureLoader.h"

@interface CDOUserImportOperationTests : XCTestCase
@property (nonatomic, strong) SQKContextManager *contextManager;
@property (nonatomic, strong) CDOUserImportOperation *operation;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation CDOUserImportOperationTests

- (void)setUp
{
    [super setUp];

    CDOGithubAPIClient *APIClientMock = OCMClassMock([CDOGithubAPIClient class]);

    NSArray *usersJSON = [CDOJSONFixtureLoader loadJSONFileNamed:@"users"];

    OCMStub([APIClientMock getUser:@"lukestringer90" error:[OCMArg anyObjectRef]]).andReturn(usersJSON[0]);
    OCMStub([APIClientMock getUser:@"blork" error:[OCMArg anyObjectRef]]).andReturn(usersJSON[1]);

    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                    managedObjectModel:model
                                        orderedManagedObjectModelNames:@[ @"SQKCoreDataOperation_Example" ]
                                                              storeURL:nil];
    self.operation = [[CDOUserImportOperation alloc] initWithContextManager:self.contextManager APIClient:APIClientMock];
    self.queue = [NSOperationQueue new];
}

- (void)testOperation
{
    __block BOOL operationFinished = NO;

    NSManagedObjectContext *context = [self.contextManager mainContext];

    User *luke = [User sqk_insertInContext:context];
    luke.username = @"lukestringer90";

    User *blork = [User sqk_insertInContext:context];
    blork.username = @"blork";

    [context save:NULL];

    [self.operation setCompletionBlock:^{
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

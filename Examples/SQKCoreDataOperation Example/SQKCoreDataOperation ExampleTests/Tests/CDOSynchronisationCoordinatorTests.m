//
//  CDOSynchronisationCoordinator.m
//  SQKCoreDataOperation Example
//
//  Created by Sam Oakley on 22/10/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CDOGithubAPIClient.h"
#import "CDOSynchronisationCoordinator.h"
#import "CDOJSONFixtureLoader.h"
#import <SQKDataKit/SQKContextManager.h>

@interface CDOSynchronisationCoordinatorTests : XCTestCase
@property (strong, nonatomic) CDOSynchronisationCoordinator *syncCoordinator;
@end

@implementation CDOSynchronisationCoordinatorTests

- (void)setUp {
    [super setUp];
    
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    SQKContextManager *contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                                  managedObjectModel:model
                                                      orderedManagedObjectModelNames:@[@"SQKCoreDataOperation_Example"]
                                                                            storeURL:nil];


    CDOGithubAPIClient *APIClientMock = OCMClassMock([CDOGithubAPIClient class]);
    
    NSArray *usersJSON = [CDOJSONFixtureLoader loadJSONFileNamed:@"users"];
    NSArray *commitsJSON = [CDOJSONFixtureLoader loadJSONFileNamed:@"commits"];

    OCMStub([APIClientMock getCommitsForRepo:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(commitsJSON);
    OCMStub([APIClientMock getUser:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(usersJSON[0]);

    self.syncCoordinator = [[CDOSynchronisationCoordinator alloc] initWithContextManager:contextManager
                                                                                                         APIClient:APIClientMock];
}


- (void)tearDown {
    [super tearDown];
    self.syncCoordinator = nil;
}

- (void)testSynchronisationNotifications
{
    [self expectationForNotification:CDOSynchronisationRequestNotification object:nil handler:nil];
    [self expectationForNotification:CDOSynchronisationResponseNotification object:nil handler:nil];

    [CDOSynchronisationCoordinator synchronise];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}


@end

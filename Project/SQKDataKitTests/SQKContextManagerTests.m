//
//  SQKContextManagerTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <SQKDataKit/SQKContextManager.h>
#import "Commit.h"
#import "NSManagedObject+SQKAdditions.h"

/**
 *  Category that redefines the private internals of SQKContextManager
 *  so we can access the properties necessary for testing.
 */
@interface SQKContextManager (TestVisibility)
@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;
@end

@interface SQKContextManagerTests : XCTestCase
@property (nonatomic, retain) SQKContextManager *contextManager;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@end

@implementation SQKContextManagerTests

- (void)setUp
{
    [super setUp];
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:@[ [NSBundle mainBundle] ]];
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                    managedObjectModel:self.managedObjectModel
                                        orderedManagedObjectModelNames:@[ @"SQKDataKitModel" ]
                                                              storeURL:nil];
}

- (void)tearDown
{
    self.contextManager.mainContext = nil;
    self.contextManager = nil;
}

#pragma mark - Helpers

- (id)mockMainContextWithStubbedHasChangesReturnValue:(BOOL)hasChanges
{
    id mock = [OCMockObject mockForClass:[NSManagedObjectContext class]];
    [[[mock stub] andReturnValue:OCMOCK_VALUE(hasChanges)] hasChanges];
    return mock;
}

#pragma mark - Initialisation

- (void)testInitialisesWithAStoreTypeAndMangedObjectModel
{
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                    managedObjectModel:self.managedObjectModel
                                        orderedManagedObjectModelNames:@[ @"SQKDataKitModel" ]
                                                              storeURL:nil];

    NSPersistentStore *store = [self.contextManager.persistentStoreCoordinator.persistentStores firstObject];
    XCTAssertNotNil(self.contextManager, @"");
    XCTAssertEqualObjects(store.type, NSInMemoryStoreType, @"");
    XCTAssertEqualObjects(self.contextManager.persistentStoreCoordinator.managedObjectModel, self.managedObjectModel, @"");
}

- (void)testReturnsNilWithNoStoreType
{
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:nil
                                                    managedObjectModel:self.managedObjectModel
                                        orderedManagedObjectModelNames:@[ @"SQKDataKitModel" ]
                                                              storeURL:nil];
    XCTAssertNil(self.contextManager, @"");
}

- (void)testReturnsNilWithNoManagedObjectModel
{
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                    managedObjectModel:nil
                                        orderedManagedObjectModelNames:@[ @"SQKDataKitModel" ]
                                                              storeURL:nil];
    XCTAssertNil(self.contextManager, @"");
}

- (void)testReturnsNilWhenUsingIncorrectStoreTypeString
{
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:@"unsupported"
                                                    managedObjectModel:self.managedObjectModel
                                        orderedManagedObjectModelNames:@[ @"SQKDataKitModel" ]
                                                              storeURL:nil];
    XCTAssertNil(self.contextManager, @"");
}

#pragma mark - Contexts

- (void)testProvidesMainContext
{
    XCTAssertNotNil([self.contextManager mainContext], @"");
}

- (void)testProvidesSameMainContext
{
    NSManagedObjectContext *firstContext = [self.contextManager mainContext];
    NSManagedObjectContext *secondContext = [self.contextManager mainContext];
    XCTAssertEqualObjects(firstContext, secondContext, @"");
}

- (void)testProvidesMainContextWithMainConcurrencyType
{
    NSManagedObjectContext *mainContext = [self.contextManager mainContext];
    XCTAssertEqual((NSInteger)mainContext.concurrencyType, (NSInteger)NSMainQueueConcurrencyType, @"");
}

- (void)testProvidesANewPrivateContext
{
    NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
    XCTAssertNotNil(privateContext, @"");
    XCTAssertEqual((NSInteger)privateContext.concurrencyType, (NSInteger)NSPrivateQueueConcurrencyType, @"");
}

- (void)testMainContextAndPrivateContextUseSamePersistentStoreCoordinator
{
    NSManagedObjectContext *mainContext = [self.contextManager mainContext];
    NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
    XCTAssertEqualObjects(mainContext.persistentStoreCoordinator, privateContext.persistentStoreCoordinator, @"");
}

- (void)testMainContextHasAStoreCoordinator
{
    XCTAssertNotNil([self.contextManager mainContext].persistentStoreCoordinator, @"");
}

- (void)testPrivateContextHasAStoreCoordinator
{
    XCTAssertNotNil([self.contextManager newPrivateContext].persistentStoreCoordinator, @"");
}

- (void)testStoreCoordinatorHasASingleStore
{
    XCTAssertTrue([self.contextManager mainContext].persistentStoreCoordinator.persistentStores.count == 1, @"");
}

- (void)testAccessingMainContextOffMainThreadThrowsException
{
	XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try
        {
            [self.contextManager.mainContext save:nil];
			XCTFail(@"Should throw exception when accessing main context off main thread");
        }
        @catch (NSException *exception)
        {
			[expectation fulfill];
        }
    });

	[self waitForExpectationsWithTimeout:2.0 handler:nil];
}

#pragma mark - Saving

- (void)testInsertsAreMergedIntoMainContextWhenPrivateContextIsSaved
{
	XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];

    NSOperationQueue *privateQueue = [[NSOperationQueue alloc] init];
    [privateQueue addOperationWithBlock:^{
        NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
        [privateContext performBlockAndWait:^{
            NSError *error = nil;
            Commit *commit = [Commit sqk_insertInContext:privateContext];
            commit.sha = @"Insert test";
            [privateContext save:&error];
            if (error)
            {
                XCTFail(@"There was an error saving! %@", [error localizedDescription]);
            }
			[expectation fulfill];
        }];
    }];

	[self waitForExpectationsWithTimeout:2.0 handler:nil];

    NSArray *fetchedObjects =
        [self.contextManager.mainContext executeFetchRequest:[Commit sqk_fetchRequest] error:nil];
    XCTAssertTrue(fetchedObjects.count == 1, @"");
    Commit *fetchedObject = fetchedObjects.firstObject;
    XCTAssertEqualObjects([fetchedObject sha], @"Insert test", @"");
}

- (void)testEditsAreMergedIntoMainContextWhenPrivateContextIsSaved
{
    Commit *commit = [Commit sqk_insertInContext:self.contextManager.mainContext];
    commit.sha = @"Edit test";
    [self.contextManager.mainContext save:nil];
    NSManagedObjectID *objectID = commit.objectID;

	XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	
    NSOperationQueue *privateQueue = [[NSOperationQueue alloc] init];
    [privateQueue addOperationWithBlock:^{
        NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
        [privateContext performBlockAndWait:^{
            NSError *error = nil;
            Commit *commit = (Commit *)[privateContext objectWithID:objectID];
            commit.sha = @"Edited in a private context";
            [privateContext save:&error];
            if (error)
            {
                XCTFail(@"There was an error saving! %@", [error localizedDescription]);
            }
			[expectation fulfill];
        }];
    }];

	[self waitForExpectationsWithTimeout:2.0 handler:nil];
    XCTAssertEqualObjects([commit sha], @"Edited in a private context", @"");
}

- (void)testPersistentStoreIsTornDown
{
    Commit *commit = [Commit sqk_insertInContext:self.contextManager.mainContext];
    
    commit.message = @"Persistent Store Tear Down";
    
    [self.contextManager.mainContext save:nil];
    
    NSFetchRequest *fetchRequest = [Commit sqk_fetchRequest];
    
    NSInteger countForFetchRequest = [self.contextManager.mainContext countForFetchRequest:fetchRequest error:nil];
    
    NSLog(@"Count for fetch request returned %li entities", countForFetchRequest);
    
    NSError *error = nil;
    
    [self.contextManager destroyAndRebuildPersistentStore:&error];
    
    countForFetchRequest = [self.contextManager.mainContext countForFetchRequest:fetchRequest error:nil];
    
    NSLog(@"Count for fetch request returned %li entities", countForFetchRequest);
    
    XCTAssertEqual(countForFetchRequest, 0);
}

@end

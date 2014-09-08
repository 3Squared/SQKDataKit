//
//  SQKContextManagerTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <AGAsyncTestHelper/AGAsyncTestHelper.h>
#import "SQKContextManager.h"
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
    self.managedObjectModel =
        [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                    managedObjectModel:self.managedObjectModel
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
                                                              storeURL:nil];
    XCTAssertNotNil(self.contextManager, @"");
    XCTAssertEqualObjects(self.contextManager.storeType, NSInMemoryStoreType, @"");
    XCTAssertEqualObjects(self.contextManager.managedObjectModel, self.managedObjectModel, @"");
}

- (void)testReturnsNilWithNoStoreType
{
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:nil
                                                    managedObjectModel:self.managedObjectModel
                                                              storeURL:nil];
    XCTAssertNil(self.contextManager, @"");
}

- (void)testReturnsNilWithNoManagedObjectModel
{
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                    managedObjectModel:nil
                                                              storeURL:nil];
    XCTAssertNil(self.contextManager, @"");
}

- (void)testReturnsNilWhenUsingIncorrectStoreTypeString
{
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:@"unsupported"
                                                    managedObjectModel:self.managedObjectModel
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
    __block BOOL exceptionThrown = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try
        {
            [self.contextManager.mainContext save:nil];
        }
        @catch (NSException *exception)
        {
            exceptionThrown = YES;
        }
    });

    AGWW_WAIT_WHILE(!exceptionThrown, 2.0);
    XCTAssertTrue(exceptionThrown, @"");
}

#pragma mark - Saving

- (void)testMergePropagatesChangesWhenMergingPrivateContextIsSaved
{
    // Don't mock, testing IRL behavior.

    NSArray *initialObjects =
        [self.contextManager.mainContext executeFetchRequest:[Commit sqk_fetchRequest] error:nil];
    XCTAssertTrue(initialObjects.count == 0, @"");

    __block BOOL inserted = NO;

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
            inserted = YES;
        }];
    }];

    AGWW_WAIT_WHILE(!inserted, 2.0);

    NSArray *fetchedObjects =
        [self.contextManager.mainContext executeFetchRequest:[Commit sqk_fetchRequest] error:nil];
    XCTAssertTrue(fetchedObjects.count == 1, @"");
    Commit *fetchedObject = fetchedObjects.firstObject;
    XCTAssertEqualObjects([fetchedObject sha], @"Insert test", @"");


    NSManagedObjectID *objectID = fetchedObject.objectID;
    __block BOOL edited = NO;
    [privateQueue addOperationWithBlock:^{
        NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
        [privateContext performBlockAndWait:^{
            NSError *error = nil;
            Commit *commit = (Commit *)[privateContext objectWithID:objectID];
            commit.sha = @"Edit test";
            [privateContext save:&error];
            if (error)
            {
                XCTFail(@"There was an error saving! %@", [error localizedDescription]);
            }
            edited = YES;
        }];
    }];

    AGWW_WAIT_WHILE(!edited, 2.0);
    [fetchedObject.managedObjectContext refreshObject:fetchedObject mergeChanges:YES];
    XCTAssertEqualObjects([fetchedObject sha], @"Edit test", @"");


    __block BOOL deleted = NO;
    [privateQueue addOperationWithBlock:^{
        NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
        [privateContext performBlockAndWait:^{
            NSError *error = nil;
            Commit *commit = (Commit *)[privateContext objectWithID:objectID];
            [privateContext deleteObject:commit];
            [privateContext save:&error];
            if (error)
            {
                XCTFail(@"There was an error saving! %@", [error localizedDescription]);
            }
            deleted = YES;
        }];
    }];

    AGWW_WAIT_WHILE(!deleted, 2.0);
    [fetchedObject.managedObjectContext refreshObject:fetchedObject mergeChanges:YES];
    
    XCTAssertTrue(!fetchedObject.isFault, @"");
    [self.contextManager.mainContext refreshObject:fetchedObject mergeChanges:NO];
    XCTAssertTrue(fetchedObject.isFault, @"");

    __block BOOL exceptionThrown = NO;
    @try
    {
        fetchedObject.sha = @"An exception should be thrown right now.";
        XCTFail(@"An exception should be thrown when accessing properties of a deleted object.");
    }
    @catch (NSException *exception)
    {
        exceptionThrown = YES;
    }

    XCTAssertTrue(exceptionThrown, @"");
}

@end

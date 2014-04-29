//
//  SQKManagedObjectControllerTests.m
//  SQKManagedObjectControllerTests
//
//  Created by Sam Oakley on 20/03/2014.
//  Copyright (c) 2014 Sam Oakley. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGAsyncTestHelper/AGAsyncTestHelper.h>
#import "SQKManagedObjectController.h"
#import "Commit.h"
#import "SQKContextManager.h"
#import "NSManagedObject+SQKAdditions.h"

@interface SQKManagedObjectControllerTests : XCTestCase <SQKManagedObjectControllerDelegate>
@property (strong, nonatomic) Commit *commit;
@property (strong, nonatomic) SQKManagedObjectController *controller;
@property (strong, nonatomic) SQKContextManager *contextManager;

@property (assign) BOOL fetchDone;
@property (assign) BOOL updateDone;
@property (assign) BOOL deletionDone;
@property (assign) BOOL localControllerUpdateDone;
@end

@implementation SQKManagedObjectControllerTests

/**
 *  Reset everything, create a new basic controller and insert a post.
 */
- (void)setUp
{
    [super setUp];
    self.fetchDone = NO;
    self.updateDone = NO;
    self.deletionDone = NO;
    self.localControllerUpdateDone = NO;
    
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType managedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    
    self.commit = [Commit SQK_insertInContext:[self.contextManager mainContext]];
    self.commit.sha = @"abcd";
    [self.contextManager saveMainContext:nil];
    
    NSFetchRequest *request = [Commit SQK_fetchRequest];
    
    self.controller = [[SQKManagedObjectController alloc] initWithFetchRequest:request
                                                          managedObjectContext:[self.contextManager mainContext]];
    self.controller.delegate = self;
    self.controller.updatedObjectsBlock = nil;
    self.controller.fetchedObjectsBlock = nil;
    self.controller.deletedObjectsBlock = nil;
}


- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 *  Test a simple fetch.
 */
-(void)testFetching
{
    NSError *error = nil;
    [self.controller performFetch:&error];
    
    XCTAssertNil(error, @"");
    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)1, @"");
    XCTAssertEqualObjects([[self.controller managedObjects] firstObject], self.commit, @"");
}

/**
 *  Test if objects are updated if modified in a background thread.
 */
- (void)testUpdating
{
    NSError *error = nil;
    
    __block bool blockUpdateDone = NO;
    self.controller.updatedObjectsBlock = ^void(NSIndexSet *indexes)
    {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockUpdateDone = YES;
    };
    
    [self.controller performFetch:&error];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext* privateContext = [self.contextManager newPrivateContext];
        [privateContext performBlockAndWait:^{
            Commit *commit = (Commit*)[privateContext objectWithID:self.commit.objectID];
            commit.sha = @"dcba";
            NSError *error = nil;
            [privateContext save:&error];
            NSLog(@"%s %d %s: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, [error localizedDescription]);
        }];
    });
    
    AGWW_WAIT_WHILE(!self.updateDone && !blockUpdateDone, 60.0);
    
    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)1, @"");
    XCTAssertEqualObjects([[[self.controller managedObjects] firstObject] sha], @"dcba", @"");
}


/**
 *  Test that objects are updated and the delegate is called if the fetch is performed off the main thread.
 */
-(void)testAsyncFetching
{
    __block bool blockFetchDone = NO;
    self.controller.fetchedObjectsBlock = ^void(NSIndexSet *indexes, NSError *error)
    {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockFetchDone = YES;
    };

    [self.controller performFetchAsynchronously];
    
    XCTAssertNil([self.controller managedObjects], @"");
    AGWW_WAIT_WHILE(!self.fetchDone && !blockFetchDone, 2.0);
    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)1, @"");
    
    Commit *commit = [[self.controller managedObjects] firstObject];
    XCTAssertEqualObjects(commit.managedObjectContext, [self.contextManager mainContext], @"");
}

/**
 *  Test that the batch deletion method correctly removes objects from the persistant store and the the delegate is notified.
 */
-(void)testDeletion
{
    [self.controller performFetch:nil];
    
    XCTAssertEqualObjects([[self.controller managedObjects] firstObject], self.commit, @"");
    
    NSError *error = nil;
    [self.controller deleteObjects:&error];
    
    XCTAssertNil(error, @"");
    
    // On deletion the context is nilled out. isDeleted returns NO, though.
    XCTAssertNil(self.commit.managedObjectContext, @"");
    XCTAssertTrue(self.commit.isFault, @"");
    XCTAssertFalse(self.commit.isInserted, @"");

    // Changing a deleted object causes Core Data to throw an exception:
    // "CoreData could not fulfill a fault"
    BOOL exceptionThrown = NO;
    @try {
        self.commit.sha = @"Deleted!";
        XCTFail(@"Core Data should throw exception with error 'CoreData could not fulfill a fault'.");
    }
    @catch (NSException *exception) {
        exceptionThrown = YES;
    }
    
    XCTAssertTrue(exceptionThrown, @"");
    
    [[self.contextManager mainContext] save:&error];
    XCTAssertNil(error, @"");
}

/**
 *  Test that the asyncrounous batch deletion method correctly removes objects from the persistant store and the the delegate is notified.
 */
-(void)testAsyncDeletion
{
    [self.controller performFetch:nil];
    
    __block bool blockDeleteDone = NO;
    self.controller.deletedObjectsBlock = ^void(NSIndexSet *indexes)
    {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockDeleteDone = YES;
    };

    
    [self.controller deleteObjectsAsynchronously];
    
    AGWW_WAIT_WHILE(!self.deletionDone && !blockDeleteDone, 60.0);
    
    // On deletion the context is nilled out. isDeleted returns NO, though.
    XCTAssertTrue(self.commit.isDeleted, @"");
    XCTAssertNil(self.commit.managedObjectContext, @"");
    XCTAssertTrue(self.commit.isFault, @"");
    XCTAssertFalse(self.commit.isInserted, @"");

    NSError *error = nil;
    // Changing a deleted object causes Core Data to throw an exception:
    // "CoreData could not fulfill a fault"
    BOOL exceptionThrown = NO;
    @try {
        self.commit.sha = @"Deleted!";
        XCTFail(@"Core Data should throw exception with error 'CoreData could not fulfill a fault'.");
    }
    @catch (NSException *exception) {
        exceptionThrown = YES;
    }
    
    XCTAssertTrue(exceptionThrown, @"");
    
    [[self.contextManager mainContext] save:&error];
    XCTAssertNil(error, @"");
}

/**
 *  Test that calling performFetch: a second time causes the managedObjects property to be updated.
 */
-(void)testFetchToRefresh
{
    [self.controller performFetch:nil];
    
    
    Commit* commit = [Commit SQK_insertInContext:[self.contextManager mainContext]];
    commit.sha = @"Another test!";
    [[self.contextManager mainContext] save:nil];
    
    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)1, @"");
    
    [self.controller performFetch:nil];
    
    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)2, @"");
    
    XCTAssertEqualObjects([[[self.controller managedObjects] firstObject] sha], @"Another test!", @"");
}

#pragma mark - Other Initialisers

/**
 *  Test that incorrect values cause init methods to return nil.
 */
-(void)testInitialisers
{
    XCTAssertNil([[SQKManagedObjectController alloc] initWithFetchRequest:nil managedObjectContext:nil], @"");
    XCTAssertNil([[SQKManagedObjectController alloc] initWithFetchRequest:nil managedObjectContext:[self.contextManager mainContext]], @"");
    XCTAssertNil([[SQKManagedObjectController alloc] initWithFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Post"] managedObjectContext:nil], @"");
    XCTAssertNil([[SQKManagedObjectController alloc] initWithWithManagedObject:nil], @"");
    XCTAssertNil([[SQKManagedObjectController alloc] initWithWithManagedObjects:nil], @"");
}

/**
 *  Test that the array wrapper initialiser causes the delegate to be called.
 */
-(void)testInitialisingWithObjects
{
    [self.controller performFetch:nil];
    self.controller.delegate = nil;
    SQKManagedObjectController *objectsController = [[SQKManagedObjectController alloc] initWithWithManagedObjects:[self.controller managedObjects]];
    objectsController.delegate = self;
    
    __block bool blockUpdateDone = NO;
    objectsController.updatedObjectsBlock = ^void(NSIndexSet *indexes)
    {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockUpdateDone = YES;
    };
    
    XCTAssertNotNil(objectsController, @"");
    
    self.commit.sha = @"Can you see me?";
    [[self.contextManager mainContext] save:nil];
    
    XCTAssertTrue(!self.localControllerUpdateDone, @"");
    AGWW_WAIT_WHILE(!self.localControllerUpdateDone && !blockUpdateDone, 2.0);
    XCTAssertTrue(self.localControllerUpdateDone, @"");
    XCTAssertEqualObjects([[[objectsController managedObjects] firstObject] sha], @"Can you see me?", @"");
}

/**
 *  Test that the object wrapper initialiser causes the delegate to be called.
 */
-(void)testInitialisingWithObject
{
    [self.controller performFetch:nil];
    self.controller.delegate = nil;
    SQKManagedObjectController *objectsController = [[SQKManagedObjectController alloc] initWithWithManagedObject:[[self.controller managedObjects] firstObject]];
    objectsController.delegate = self;
    
    __block bool blockUpdateDone = NO;
    objectsController.updatedObjectsBlock = ^void(NSIndexSet *indexes)
    {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockUpdateDone = YES;
    };
    
    XCTAssertNotNil(objectsController, @"");
    
    self.commit.sha = @"Can you see me?";
    [[self.contextManager mainContext] save:nil];
    
    XCTAssertTrue(!self.localControllerUpdateDone, @"");
    AGWW_WAIT_WHILE(!self.localControllerUpdateDone && !blockUpdateDone, 2.0);
    XCTAssertTrue(self.localControllerUpdateDone, @"");
    XCTAssertEqualObjects([[[objectsController managedObjects] firstObject] sha], @"Can you see me?", @"");
}

/**
 *  Test wrapping an existing object with background changes.
 */
-(void)testInitialisingWithObjectAsync
{
    [self.controller performFetch:nil];
    self.controller.delegate = nil;
    SQKManagedObjectController *objectsController = [[SQKManagedObjectController alloc] initWithWithManagedObject:[[self.controller managedObjects] firstObject]];
    objectsController.delegate = self;
    
    __block bool blockUpdateDone = NO;
    objectsController.updatedObjectsBlock = ^void(NSIndexSet *indexes)
    {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockUpdateDone = YES;
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext* privateContext = [self.contextManager newPrivateContext];
        [privateContext performBlockAndWait:^{
            Commit *commit = (Commit*)[privateContext objectWithID:self.commit.objectID];
            commit.sha = @"Can you see me?";
            [privateContext save:nil];
        }];
    });

    XCTAssertTrue(!self.localControllerUpdateDone, @"");
    AGWW_WAIT_WHILE(!self.localControllerUpdateDone && !blockUpdateDone, 2.0);
    XCTAssertTrue(self.localControllerUpdateDone, @"");
    XCTAssertEqual([[objectsController managedObjects] count], (NSUInteger)1, @"");
    XCTAssertEqualObjects([[[objectsController managedObjects] firstObject] sha], @"Can you see me?", @"");

}

#pragma mark - Delegate

-(void)controller:(SQKManagedObjectController *)controller fetchedObjects:(NSIndexSet *)fetchedObjectIndexes error:(NSError **)error
{
    XCTAssertTrue([NSThread isMainThread], @"");
    if (controller == self.controller) {
        self.fetchDone = YES;
    }
}

-(void)controller:(SQKManagedObjectController *)controller updatedObjects:(NSIndexSet *)changedObjectIndexes
{
    XCTAssertTrue([NSThread isMainThread], @"");
    if (controller == self.controller) {
        self.updateDone = YES;
    } else {
        self.localControllerUpdateDone = YES;
    }
}


-(void)controller:(SQKManagedObjectController *)controller deletedObjects:(NSIndexSet *)deletedObjectIndexes
{
    XCTAssertTrue([NSThread isMainThread], @"");
    if (controller == self.controller) {
        self.deletionDone = YES;
    }
}

@end

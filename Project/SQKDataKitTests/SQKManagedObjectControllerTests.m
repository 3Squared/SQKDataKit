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
#import "User.h"
#import "SQKContextManager.h"
#import "NSManagedObject+SQKAdditions.h"

@interface SQKManagedObjectControllerTests : XCTestCase
@property (strong, nonatomic) Commit *commit;
@property (strong, nonatomic) SQKManagedObjectController *controller;
@property (strong, nonatomic) SQKContextManager *contextManager;
@end

@implementation SQKManagedObjectControllerTests

/**
 *  Reset everything, create a new basic controller and insert a post.
 */
- (void)setUp
{
    [super setUp];

    NSManagedObjectModel *managedObjectModel =
        [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                    managedObjectModel:managedObjectModel
                                                              storeURL:nil];

    self.commit = [Commit sqk_insertInContext:[self.contextManager mainContext]];
    self.commit.sha = @"abcd";
    self.commit.date = [NSDate date];
    [[self.contextManager mainContext] save:NULL];

    NSFetchRequest *request = [Commit sqk_fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];

    self.controller =
        [[SQKManagedObjectController alloc] initWithFetchRequest:request
                                            managedObjectContext:[self.contextManager mainContext]];
    self.controller.savedObjectsBlock = nil;
    self.controller.fetchedObjectsBlock = nil;
    self.controller.deletedObjectsBlock = nil;
}


- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the
    // class.
    [super tearDown];
    self.commit = nil;
    self.controller = nil;
    self.contextManager = nil;
}

/**
 *  Test a simple fetch.
 */
- (void)testFetching
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
    self.controller.savedObjectsBlock = ^void(SQKManagedObjectController *controller, NSIndexSet *indexes) {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockUpdateDone = YES;
    };

    [self.controller performFetch:&error];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
        [privateContext performBlockAndWait:^{
            Commit *commit = (Commit *)[privateContext objectWithID:self.commit.objectID];
            commit.sha = @"dcba";
            NSError *error = nil;
            [privateContext save:&error];
            NSLog(@"%s %d %s: %@", __FILE__, __LINE__, __PRETTY_FUNCTION__, [error localizedDescription]);
        }];
    });

    AGWW_WAIT_WHILE(!blockUpdateDone, 20.0);
    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)1, @"");
    XCTAssertEqualObjects([[[self.controller managedObjects] firstObject] sha], @"dcba", @"");
}

/**
 *  Test block is called when object changed.
 */
- (void)testInsertRefresh
{
    [self.controller performFetch:nil];

    __block bool blockUpdateDone = NO;
    self.controller.insertedObjectsBlock = ^void(SQKManagedObjectController *controller, NSIndexSet *indexes) {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockUpdateDone = YES;
    };

    Commit *commit = [Commit sqk_insertInContext:[self.contextManager mainContext]];
    commit.sha = @"Insert 1";
    commit.date = [NSDate date];

    Commit *commit2 = [Commit sqk_insertInContext:[self.contextManager mainContext]];
    commit2.sha = @"Insert 2";
    commit2.date = [NSDate date];

    [[self.contextManager mainContext] save:NULL];

    AGWW_WAIT_WHILE(!blockUpdateDone, 2.0);
    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)3, @"");
    XCTAssertTrue([self.controller.managedObjects containsObject:self.commit], @"");
    XCTAssertTrue([self.controller.managedObjects containsObject:commit], @"");
    XCTAssertTrue([self.controller.managedObjects containsObject:commit2], @"");
}

/**
 *  Test that the batch deletion method correctly removes objects from the persistant store and the
 * the delegate is notified.
 */
- (void)testDeletion
{
    [self.controller performFetch:nil];

    XCTAssertEqualObjects([[self.controller managedObjects] firstObject], self.commit, @"");

    NSError *error = nil;
    [self.controller deleteObjects:&error];
    XCTAssertNil(error, @"");
    [self.controller.managedObjectContext save:nil];

    // On deletion the context is nilled out. isDeleted returns NO, though.
    XCTAssertNil(self.commit.managedObjectContext, @"");
    XCTAssertTrue(self.commit.isFault, @"");
    XCTAssertFalse(self.commit.isInserted, @"");

    // Changing a deleted object causes Core Data to throw an exception:
    // "CoreData could not fulfill a fault"
    BOOL exceptionThrown = NO;
    @try
    {
        self.commit.sha = @"Deleted!";
        XCTFail(
            @"Core Data should throw exception with error 'CoreData could not fulfill a fault'.");
    }
    @catch (NSException *exception)
    {
        exceptionThrown = YES;
    }

    XCTAssertTrue(exceptionThrown, @"");

    [[self.contextManager mainContext] save:&error];
    XCTAssertNil(error, @"");
}

- (void)testDeletionWithPredicate
{
    NSError *error = nil;
    NSManagedObjectContext *context = [self.contextManager mainContext];
    
    Commit *commit = [Commit sqk_insertInContext:context];
    commit.sha = @"To delete";
    commit.date = [NSDate date];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sha == 'To delete'"];
    [Commit sqk_deleteAllObjectsInContext:context withPredicate:predicate error:&error];
    XCTAssertNil(error, @"");
    
    [context save:&error];
    XCTAssertNil(error, @"");
    
    NSFetchRequest *fetchRequest = [Commit sqk_fetchRequest];
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    XCTAssertNil(error, @"");
    
    Commit *fetchedCommit = [objects firstObject];
    
    XCTAssertEqual([objects count], (NSUInteger)1, @"");
    XCTAssertEqual(fetchedCommit.sha, @"abcd");
}

#pragma mark - Other Initialisers

/**
 *  Test that incorrect values cause init methods to return nil.
 */
- (void)testInitialisers
{
    XCTAssertNil(
        [[SQKManagedObjectController alloc] initWithFetchRequest:nil managedObjectContext:nil], @"");
    XCTAssertNil([[SQKManagedObjectController alloc] initWithFetchRequest:nil
                                                     managedObjectContext:[self.contextManager mainContext]],
                 @"");
    XCTAssertNil([[SQKManagedObjectController alloc] initWithFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Post"]
                                                     managedObjectContext:nil],
                 @"");
    XCTAssertNil([[SQKManagedObjectController alloc] initWithManagedObject:nil], @"");
    XCTAssertNil([[SQKManagedObjectController alloc] initWithManagedObjects:nil], @"");
}

/**
 *  Test that the array wrapper initialiser causes the delegate to be called.
 */
- (void)testInitialisingWithObjects
{
    [self.controller performFetch:nil];
    self.controller.delegate = nil;
    SQKManagedObjectController *objectsController =
        [[SQKManagedObjectController alloc] initWithManagedObjects:[self.controller managedObjects]];

    __block bool blockUpdateDone = NO;
    objectsController.savedObjectsBlock = ^void(SQKManagedObjectController *controller, NSIndexSet *indexes) {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockUpdateDone = YES;
    };

    XCTAssertNotNil(objectsController, @"");

    self.commit.sha = @"Can you see me?";
    [[self.contextManager mainContext] save:nil];

    AGWW_WAIT_WHILE(!blockUpdateDone, 2.0);
    XCTAssertEqualObjects([[[objectsController managedObjects] firstObject] sha],
                          @"Can you see me?",
                          @"");
}

/**
 *  Test that the object wrapper initialiser causes the delegate to be called.
 */
- (void)testInitialisingWithObject
{
    [self.controller performFetch:nil];
    self.controller.delegate = nil;
    SQKManagedObjectController *objectsController =
        [[SQKManagedObjectController alloc] initWithManagedObject:[[self.controller managedObjects] firstObject]];

    __block bool blockUpdateDone = NO;
    objectsController.savedObjectsBlock = ^void(SQKManagedObjectController *controller, NSIndexSet *indexes) {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockUpdateDone = YES;
    };

    XCTAssertNotNil(objectsController, @"");

    self.commit.sha = @"Can you see me?";
    [[self.contextManager mainContext] save:nil];

    AGWW_WAIT_WHILE(!blockUpdateDone, 20.0);
    XCTAssertEqualObjects([[[objectsController managedObjects] firstObject] sha],
                          @"Can you see me?",
                          @"");
}

/**
 *  Test wrapping an existing object with background changes.
 */
- (void)testInitialisingWithObjectAsync
{
    [self.controller performFetch:nil];
    self.controller.delegate = nil;
    SQKManagedObjectController *objectsController =
        [[SQKManagedObjectController alloc] initWithManagedObject:[[self.controller managedObjects] firstObject]];

    __block bool blockUpdateDone = NO;
    objectsController.savedObjectsBlock = ^void(SQKManagedObjectController *controller, NSIndexSet *indexes) {
        XCTAssertTrue([NSThread isMainThread], @"");
        blockUpdateDone = YES;
    };

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
        [privateContext performBlockAndWait:^{
            Commit *commit = (Commit *)[privateContext objectWithID:self.commit.objectID];
            commit.sha = @"Can you see me?";
            [privateContext save:nil];
        }];
    });

    AGWW_WAIT_WHILE(!blockUpdateDone, 2.0);
    XCTAssertEqual([[objectsController managedObjects] count], (NSUInteger)1, @"");
    XCTAssertEqualObjects([[[objectsController managedObjects] firstObject] sha],
                          @"Can you see me?",
                          @"");
}

- (void)testFilteringBlock
{
    self.controller.filterReturnedObjectsBlock = ^BOOL(NSManagedObject *obj) { return NO; };

    Commit *commit = [Commit sqk_insertInContext:[self.contextManager mainContext]];
    commit.sha = @"Insert 1";
    commit.date = [NSDate date];

    Commit *commit2 = [Commit sqk_insertInContext:[self.contextManager mainContext]];
    commit2.sha = @"Insert 2";
    commit2.date = [NSDate date];

    [[self.contextManager mainContext] save:NULL];


    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)0, @"");

    // ****

    Commit *commit3 = [Commit sqk_insertInContext:[self.contextManager mainContext]];
    commit3.sha = @"Insert 3";
    commit3.date = [NSDate date];
    [[self.contextManager mainContext] save:NULL];


    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)0, @"");

    // ****

    self.controller.filterReturnedObjectsBlock = ^BOOL(NSManagedObject *obj) { return YES; };

    [self.controller performFetch:nil];

    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)4, @"");

    // ****

    self.controller.filterReturnedObjectsBlock
        = ^BOOL(Commit *obj) { return [obj.sha rangeOfString:@"Insert"].location != NSNotFound; };

    [self.controller performFetch:nil];

    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)3, @"");
}

/**
 *  Test that only objects that match the entity type specified by the request are fetched.
 */
- (void)testFetchedEntitiesAreOfCorrectType
{
    User *user = [User sqk_insertInContext:[self.contextManager mainContext]];
    user.name = @"Sam";

    Commit *commit = [Commit sqk_insertInContext:[self.contextManager mainContext]];
    commit.sha = @"Insert 1";
    commit.date = [NSDate date];
    
    User *user1 = [User sqk_insertInContext:[self.contextManager mainContext]];
    user1.name = @"Luke";


    [[self.contextManager mainContext] save:NULL];

    __block bool blockUpdateDone = NO;
    self.controller.insertedObjectsBlock = ^void(SQKManagedObjectController *controller, NSIndexSet *indexes) {
        blockUpdateDone = YES;
    };


    AGWW_WAIT_WHILE(!blockUpdateDone, 2.0);
    
    XCTAssertEqual([[self.controller managedObjects] count], (NSUInteger)1, @"");
    
    NSManagedObject *fetchedObject = [[self.controller managedObjects] firstObject];
    
    XCTAssertTrue([fetchedObject isKindOfClass:[Commit class]], @"");
}



@end

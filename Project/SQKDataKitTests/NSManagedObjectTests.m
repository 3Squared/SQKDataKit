//
//  NSManagedObjectTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 05/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreData/NSManagedObject.h>
#import "NSManagedObject+SQKAdditions.h"
#import "Commit.h"
#import "SQKContextManager.h"

@interface NSManagedObjectTests : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSManagedObjectContext *privateContext;
@end

@implementation NSManagedObjectTests

#pragma mark - setUp / tearDown

- (void)setUp
{
    [super setUp];
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    SQKContextManager *contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                                  managedObjectModel:model
                                                      orderedManagedObjectModelNames:@[ @"SQKDataKitModel" ]
                                                                            storeURL:nil];
    self.privateContext = [contextManager newPrivateContext];
    self.mainContext = [contextManager mainContext];
}

- (void)tearDown
{
    /**
     *  Reset each time so that all MOs due not persists between tests.
     */
    [self.mainContext reset];
}

#pragma mark - Testing Commitname

- (void)testEntityName
{
    XCTAssertEqualObjects([Commit sqk_entityName], @"Commit", @"");
}

- (void)testReturnsNilEntityNameWhenCalledOnNSManagedObject
{
    XCTAssertNil([NSManagedObject sqk_entityName], @"");
}

#pragma mark - Testing Commitdescription

- (void)testEntityDescriptionInContext
{
    NSEntityDescription *entityDescription = [Commit sqk_entityDescriptionInContext:self.mainContext];

    XCTAssertEqualObjects(entityDescription.name, @"Commit", @"");
}

#pragma mark - Testing property descrition

- (void)testPropertyDescription
{
    NSPropertyDescription *propertyDescription = [Commit sqk_propertyDescriptionForName:@"sha" context:self.mainContext];
    XCTAssertEqualObjects(propertyDescription.name, @"sha", @"");
}

#pragma mark - Test fetch request

- (void)testFetchRequest
{
    NSFetchRequest *fetchRequest = [Commit sqk_fetchRequest];
    XCTAssertNotNil(fetchRequest, @"");
    XCTAssertEqualObjects(fetchRequest.entityName, @"Commit", @"");
}

#pragma mark - Test basic insertion

- (void)testInsertsIntoContext
{
    Commit *commit = [Commit sqk_insertInContext:self.mainContext];
    XCTAssertNotNil(commit, @"");

    commit.sha = @"abcd";

    NSEntityDescription *entityDescription = [Commit sqk_entityDescriptionInContext:self.mainContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];

    NSError *error = nil;
    NSArray *array = [self.mainContext executeFetchRequest:fetchRequest error:&error];
    XCTAssertNil(error, @"");
    XCTAssertTrue(array.count == 1, @"");

    Commit *fetchedCommit = array[0];
    XCTAssertEqualObjects(fetchedCommit.sha, @"abcd", @"");
}

#pragma mark - Test find or fetch

- (void)testUsesInsertNewEntityWhenUnique
{
    NSError *error = nil;
    Commit *commit = [Commit sqk_insertOrFetchWithKey:@"sha"
                                                value:@"abcd"
                                              context:self.mainContext
                                                error:&error];

    XCTAssertNil(error, @"");
    XCTAssertNotNil(commit, @"");
    XCTAssertEqualObjects(commit.sha, @"abcd", @"");
}

- (void)testUsesFetchWhenNotUnique
{
    Commit *existingCommit = [Commit sqk_insertInContext:self.mainContext];
    existingCommit.sha = @"wxyz";

    NSError *error = nil;
    Commit *newCommit = [Commit sqk_insertOrFetchWithKey:@"sha"
                                                   value:@"wxyz"
                                                 context:self.mainContext
                                                   error:&error];
    XCTAssertNil(error, @"");
    XCTAssertNotNil(newCommit, @"");
    XCTAssertEqualObjects(newCommit.sha, @"wxyz", @"");
    XCTAssertEqualObjects(newCommit, existingCommit, @"");
}

#pragma mark - Test deletion

- (void)testDeletesObject
{
    Commit *commit = [Commit sqk_insertInContext:self.mainContext];
    id objectID = commit.objectID;

    [commit sqk_deleteObject];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Commit"
                                   inManagedObjectContext:self.mainContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"objectID == %@", objectID]];
    NSError *error;
    NSArray *objects = [self.mainContext executeFetchRequest:request error:&error];
    XCTAssertNil(error, @"");
    XCTAssertTrue(objects.count == 0, @"");
}

- (void)testDeleteAllObjectsInContext
{
    for (NSInteger i = 0; i < 10; ++i)
    {
        [Commit sqk_insertInContext:self.mainContext];
    }

    NSError *deleteError = nil;
    [Commit sqk_deleteAllObjectsInContext:self.mainContext error:&deleteError];
    XCTAssertNil(deleteError, @"");

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Commit"
                                   inManagedObjectContext:self.mainContext]];

    NSError *fetchError = nil;
    NSArray *objects = [self.mainContext executeFetchRequest:request error:&fetchError];
    XCTAssertNil(fetchError, @"");
    XCTAssertEqual((NSInteger)objects.count, (NSInteger)0, @"");
}

#pragma mark - Test batch insert or update

- (void)testInsertOrUpdateCallsPropertySetterBlockForEach
{
    __block NSInteger blockCallCount = 0;
    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary *dictionary, NSManagedObject *managedObject) { ++blockCallCount; };

    NSArray *dictArray = @[
        @{ @"sha" : @"123" },
        @{ @"sha" : @"456" },
        @{ @"sha" : @"789" }
    ];
    __block NSError *error = nil;
    [self.privateContext performBlockAndWait:^{
        [Commit sqk_insertOrUpdate:dictArray
                    uniqueModelKey:@"sha"
                   uniqueRemoteKey:@"sha"
               propertySetterBlock:propertySetterBlock
                    privateContext:self.privateContext
                             error:&error];
    }];

    XCTAssertNil(error, @"");
    XCTAssertEqual(blockCallCount, (NSInteger)3, @"");
}

- (void)testInsertOrUpdateCallsPropertyBlockWithDictionaryAndManagedObject
{
    __block NSDictionary *capturedDictionary = nil;
    __block NSManagedObject *capturedManagedObject;
    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary *dictionary, NSManagedObject *managedObject) {
        capturedDictionary = dictionary;
        capturedManagedObject = managedObject;
    };

    NSDictionary *propertyDictionary = @{ @"sha" : @"123" };
    NSArray *dictArray = @[ propertyDictionary ];

    __block NSError *error = nil;
    [self.privateContext performBlockAndWait:^{
        [Commit sqk_insertOrUpdate:dictArray
                    uniqueModelKey:@"sha"
                   uniqueRemoteKey:@"sha"
               propertySetterBlock:propertySetterBlock
                    privateContext:self.privateContext
                             error:&error];
    }];

    XCTAssertNil(error, @"");
    XCTAssertEqual(capturedDictionary, propertyDictionary, @"");
    XCTAssertTrue([capturedManagedObject isKindOfClass:[Commit class]], @"");
}

- (void)testInsertsAllNewObjectsInInsertOrUpdateWithSameLocalAndRemoteKeys
{
    NSArray *dictArray = @[
        @{ @"sha" : @"123" },
        @{ @"sha" : @"456" },
        @{ @"sha" : @"789" }
    ];
    __block NSError *insertOrUpdateError = nil;
    [self.privateContext performBlockAndWait:^{
        [Commit sqk_insertOrUpdate:dictArray
                    uniqueModelKey:@"sha"
                   uniqueRemoteKey:@"sha"
               propertySetterBlock:nil
                    privateContext:self.privateContext
                             error:&insertOrUpdateError];
    }];

    XCTAssertNil(insertOrUpdateError, @"");

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Commit"
                                   inManagedObjectContext:self.mainContext]];
    [self.privateContext performBlockAndWait:^{
        NSError *fetchError = nil;
        NSArray *objects = [self.privateContext executeFetchRequest:request error:&fetchError];
        XCTAssertNil(fetchError, @"");
        XCTAssertTrue(objects.count == 3, @"");
    }];
}

- (void)testInsertsWithCorrectUniqueKeySet
{
    NSArray *dictArray = @[
        @{ @"sha" : @"123" },
        @{ @"sha" : @"456" },
        @{ @"sha" : @"789" }
    ];
    __block NSError *insertOrUpdateError = nil;
    [self.privateContext performBlockAndWait:^{
        [Commit sqk_insertOrUpdate:dictArray
                    uniqueModelKey:@"sha"
                   uniqueRemoteKey:@"sha"
               propertySetterBlock:nil
                    privateContext:self.privateContext
                             error:&insertOrUpdateError];
    }];

    XCTAssertNil(insertOrUpdateError, @"");

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Commit"
                                   inManagedObjectContext:self.mainContext]];

    [self.privateContext performBlockAndWait:^{
        NSArray *objects = nil;
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"sha == %@", @"123"]];
        objects = [self.privateContext executeFetchRequest:request error:nil];
        XCTAssertEqual((NSInteger)objects.count, 1, @"");
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"sha == %@", @"456"]];
        objects = [self.privateContext executeFetchRequest:request error:nil];
        XCTAssertEqual((NSInteger)objects.count, 1, @"");
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"sha == %@", @"789"]];
        objects = [self.privateContext executeFetchRequest:request error:nil];
        XCTAssertEqual((NSInteger)objects.count, 1, @"");
    }];
}

- (void)testInsertsNewObjectsInInsertOrUpdateWithDifferingLocalAndRemoteUniqueKeys
{
    NSArray *dictArray = @[
        @{ @"remote-sha" : @"123" },
        @{ @"remote-sha" : @"456" },
        @{ @"remote-sha" : @"789" }
    ];
    __block NSError *insertOrUpdateError = nil;
    [self.privateContext performBlockAndWait:^{
        [Commit sqk_insertOrUpdate:dictArray
                    uniqueModelKey:@"sha"
                   uniqueRemoteKey:@"remote-sha"
               propertySetterBlock:nil
                    privateContext:self.privateContext
                             error:&insertOrUpdateError];
    }];

    XCTAssertNil(insertOrUpdateError, @"");

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Commit"
                                   inManagedObjectContext:self.mainContext]];
    [self.privateContext performBlockAndWait:^{
        NSError *fetchError;
        NSArray *objects = [self.privateContext executeFetchRequest:request error:&fetchError];
        XCTAssertNil(fetchError, @"");
        XCTAssertTrue(objects.count == 3, @"");
    }];
}

- (void)testUpdatesExistingObjectsWithSameLocalAndRemoteKeys
{
    __block Commit *existingCommit = nil;
    [self.privateContext performBlockAndWait:^{
        existingCommit = [Commit sqk_insertInContext:self.privateContext];
        existingCommit.sha = @"123";
        existingCommit.message = @"existing";
        [self.privateContext save:nil];
    }];

    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary *dictionary, Commit *entity) {
        entity.message = dictionary[@"message"];
    };

    NSArray *dictArray = @[
        @{ @"sha" : @"123",
           @"message" : @"updated" },
    ];
    __block NSError *insertOrUpdateError = nil;
    [self.privateContext performBlockAndWait:^{
        [Commit sqk_insertOrUpdate:dictArray
                    uniqueModelKey:@"sha"
                   uniqueRemoteKey:@"sha"
               propertySetterBlock:propertySetterBlock
                    privateContext:self.privateContext
                             error:&insertOrUpdateError];
    }];

    XCTAssertNil(insertOrUpdateError, @"");

    [self.privateContext performBlockAndWait:^{
        [self.privateContext refreshObject:existingCommit mergeChanges:YES];
        XCTAssertEqualObjects(existingCommit.message, @"updated", @"");
    }];
}

- (void)testUpdatesObjectsWithDifferingLocalAndRemoteKeys
{
    __block Commit *existingCommit = nil;
    [self.privateContext performBlockAndWait:^{
         existingCommit = [Commit sqk_insertInContext:self.privateContext];
        existingCommit.sha = @"123";
        existingCommit.message = @"existing";
    }];

    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary *dictionary, Commit *entity) {
        entity.message = dictionary[@"message"];
    };

    NSArray *dictArray = @[
        @{ @"remote-sha" : @"123",
           @"message" : @"updated" }
    ];
    __block NSError *insertOrUpdateError = nil;
    [self.privateContext performBlockAndWait:^{
        [Commit sqk_insertOrUpdate:dictArray
                    uniqueModelKey:@"sha"
                   uniqueRemoteKey:@"remote-sha"
               propertySetterBlock:propertySetterBlock
                    privateContext:self.privateContext
                             error:&insertOrUpdateError];
    }];

    XCTAssertNil(insertOrUpdateError, @"");

    [self.privateContext performBlockAndWait:^{
        [self.privateContext refreshObject:existingCommit mergeChanges:YES];
        XCTAssertEqualObjects(existingCommit.message, @"updated", @"");
    }];
}

- (void)testInsertsStubObjectsWhenOnlyUniqueModelKeyValuesAreSpecified
{
    __block NSInteger blockCallCount = 0;
    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary *dictionary, NSManagedObject *managedObject) { ++blockCallCount; };

    NSArray *commitHashes = @[ @"sha-abc", @"sha-def", @"sha-ghi" ];

    __block NSError *error = nil;
    [self.privateContext performBlockAndWait:^{
        [Commit sqk_insertOrUpdate:commitHashes
                    uniqueModelKey:@"sha"
                   uniqueRemoteKey:@"self"
               propertySetterBlock:propertySetterBlock
                    privateContext:self.privateContext
                             error:&error];
    }];

    XCTAssertNil(error, @"");
    XCTAssertEqual(blockCallCount, (NSInteger)3, @"");
}

#pragma mark - Errors

- (void)testInsertOrUpdateFailsWithUnsupportedConcurencyTypeError
{
    __block NSError *insertOrUpdateError = nil;
    [self.privateContext performBlockAndWait:^{
        [Commit sqk_insertOrUpdate:@[]
                    uniqueModelKey:@"unusedKey"
                   uniqueRemoteKey:@"unusedKey"
               propertySetterBlock:nil
                    privateContext:self.mainContext
                             error:&insertOrUpdateError];
    }];

    XCTAssertNotNil(insertOrUpdateError, @"");
    XCTAssertEqualObjects(insertOrUpdateError.domain, SQKDataKitErrorDomain, @"");
    XCTAssertEqual(insertOrUpdateError.code, (NSInteger)SQKDataKitErrorUnsupportedQueueConcurencyType, @"");
}

- (void)testInsertOrUpdateFailsSilentlyWithWithoutErrorPointer
{
    /**
     *  Necessary as there was a bug where not passing an error pointer caused a exc_bad_access
     * crash.
     */
    [self.privateContext performBlockAndWait:^{
        [Commit sqk_insertOrUpdate:@[]
                    uniqueModelKey:@"unusedKey"
                   uniqueRemoteKey:@"unusedKey"
               propertySetterBlock:nil
                    privateContext:self.mainContext
                             error:nil];
    }];
}

@end

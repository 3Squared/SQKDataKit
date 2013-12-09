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
#import "Entity.h"
#import "SQKContextManager.h"

@interface NSManagedObjectTests : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSManagedObjectContext *privateContext;
@end

@implementation NSManagedObjectTests

#pragma mark - setUp / tearDown

- (void)setUp {
    [super setUp];
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    SQKContextManager *contextManager = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType managedObjectModel:model];
    self.privateContext = [contextManager newPrivateContext];
    self.mainContext = [contextManager mainContext];
}

- (void)tearDown {
    [self deleteAllEntityObjects];
}

#pragma mark - Helpers

- (void)deleteAllEntityObjects {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.mainContext]];
    // Only fetch the managedObjectID
    [request setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *entities = [self.mainContext executeFetchRequest:request error:&error];
    if (error) {
        abort();
    }
    
    for (NSManagedObject *entity in entities) {
        [self.mainContext deleteObject:entity];
    }
    
    error = nil;
    [self.mainContext save:&error];
    if (error) {
        abort();
    }
}

#pragma mark - Testing entity name

- (void)testEntityName {
    XCTAssertEqualObjects([Entity SQK_entityName], @"Entity", @"");
}

- (void)testReturnsNilEntityNameWhenCalledOnNSManagedObject {
    XCTAssertNil([NSManagedObject SQK_entityName], @"");
}

#pragma mark - Testing entity description

- (void)testEntityDescriptionInContext {
    NSEntityDescription *entityDescription = [Entity SQK_entityDescriptionInContext:self.mainContext];
    
    XCTAssertEqualObjects(entityDescription.name, @"Entity", @"");
}

#pragma mark - Testing property descrition

- (void)testPropertyDescription {
    NSPropertyDescription *propertyDescription = [Entity SQK_propertyDescriptionForName:@"title" context:self.mainContext];
    XCTAssertEqualObjects(propertyDescription.name, @"title", @"");
}

#pragma mark - Test fetch request

- (void)testFetchRequest {
    NSFetchRequest *fetchRequest = [Entity SQK_fetchRequest];
    XCTAssertNotNil(fetchRequest, @"");
    XCTAssertEqualObjects(fetchRequest.entityName, @"Entity", @"");
}

#pragma mark - Test basic insertion

- (void)testInsertsIntoContext {
    Entity *entity = [Entity SQK_insertInContext:self.mainContext];
    XCTAssertNotNil(entity, @"");
    
    entity.uniqueID = @"1234";
    
    NSEntityDescription *entityDescription = [Entity SQK_entityDescriptionInContext:self.mainContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *array = [self.mainContext executeFetchRequest:fetchRequest error:&error];
    XCTAssertNil(error, @"");
    XCTAssertTrue(array.count == 1, @"");
    
    Entity *fetchedEntity = array[0];
    XCTAssertEqualObjects(fetchedEntity.uniqueID, @"1234", @"");
}

#pragma mark - Test find or insert

- (void)testInsertsNewEntityWhenUnique {
    NSError *error = nil;
    Entity *entity = [Entity SQK_insertOrFetchWithKey:@"uniqueID" value:@"abcd" context:self.mainContext error:&error];
    
    XCTAssertNil(error, @"");
    XCTAssertNotNil(entity, @"");
    XCTAssertEqualObjects(entity.uniqueID, @"abcd", @"");
}

- (void)testFindsExistingWhenNotUnique {
    Entity *existingEntity = [Entity SQK_insertInContext:self.mainContext];
    existingEntity.uniqueID = @"wxyz";
    
    NSError *error = nil;
    Entity *newEntity = [Entity SQK_insertOrFetchWithKey:@"uniqueID" value:@"wxyz" context:self.mainContext error:&error];
    XCTAssertNil(error, @"");
    XCTAssertNotNil(newEntity, @"");
    XCTAssertEqualObjects(newEntity.uniqueID, @"wxyz", @"");
    XCTAssertEqualObjects(newEntity, existingEntity, @"");
}

#pragma mark - Test deletion

- (void)testDeletesObject {
    Entity *entity = [Entity SQK_insertInContext:self.mainContext];
    id objectID = entity.objectID;
    
    [entity SQK_deleteObject];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.mainContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"objectID == %@", objectID]];
    NSError *error;
    NSArray *objects = [self.mainContext executeFetchRequest:request error:&error];
    XCTAssertNil(error, @"");
    XCTAssertTrue(objects.count == 0, @"");
}

- (void)testDeleteAllObjectsInContext {
    for (NSInteger i = 0; i < 10; ++i) {
        [Entity SQK_insertInContext:self.mainContext];
    }
    
    NSError *deleteError = nil;
    [Entity SQK_deleteAllObjectsInContext:self.mainContext error:&deleteError];
    XCTAssertNil(deleteError, @"");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.mainContext]];
    
    NSError *fetchError = nil;
    NSArray *objects = [self.mainContext executeFetchRequest:request error:&fetchError];
    XCTAssertNil(fetchError, @"");
    XCTAssertEqual((NSInteger)objects.count, (NSInteger)0, @"");
}

#pragma mark - Test batch insert or update

- (void)testInsertOrUpdateCallsPropertySetterBlockForEach {
    __block NSInteger blockCallCount = 0;
    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary* dictionary, NSManagedObject *managedObject) {
        ++blockCallCount;
    };
    
    NSArray *dictArray = @[@{@"uniqueID" : @"123"}, @{@"uniqueID" : @"456"}, @{@"uniqueID" : @"789"}];
    NSError *error = nil;
    [Entity SQK_insertOrUpdate:dictArray
                uniqueModelKey:@"uniqueID"
               uniqueRemoteKey:@"uniqueID"
           propertySetterBlock:propertySetterBlock
                       privateContext:self.privateContext
                         error:&error];
    
    XCTAssertNil(error, @"");
    XCTAssertEqual(blockCallCount, (NSInteger)3, @"");
}

- (void)testInserOrUpdateCallsPropertyBlockWithDictionaryAndManagedObject {
    __block NSDictionary *capturedDictionary = nil;
    __block NSManagedObject *capturedManagedObject;
    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary* dictionary, NSManagedObject *managedObject) {
        capturedDictionary = dictionary;
        capturedManagedObject = managedObject;
    };
    
    NSDictionary *propertyDictionary = @{@"uniqueID" : @"123"};
    NSArray *dictArray = @[propertyDictionary];
    
    NSError *error = nil;
    [Entity SQK_insertOrUpdate:dictArray
                uniqueModelKey:@"uniqueID"
               uniqueRemoteKey:@"uniqueID"
           propertySetterBlock:propertySetterBlock
                       privateContext:self.privateContext
                         error:&error];
    
    XCTAssertNil(error, @"");
    XCTAssertEqual(capturedDictionary, propertyDictionary, @"");
    XCTAssertTrue([capturedManagedObject isKindOfClass:[Entity class]], @"");
}

- (void)testInsertsAllNewObjectsInInsertOrUpdateWithSameLocalAndRemoteUniqueKeys {
    NSArray *dictArray = @[@{@"uniqueID" : @"123"}, @{@"uniqueID" : @"456"}, @{@"uniqueID" : @"789"}];
    NSError *insertOrUpdateError = nil;
    [Entity SQK_insertOrUpdate:dictArray
                uniqueModelKey:@"uniqueID"
               uniqueRemoteKey:@"uniqueID"
           propertySetterBlock:nil
                       privateContext:self.privateContext
                         error:&insertOrUpdateError];
    
    XCTAssertNil(insertOrUpdateError, @"");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.mainContext]];
    NSError *fetchError;
    NSArray *objects = [self.privateContext executeFetchRequest:request error:&fetchError];
    XCTAssertNil(fetchError, @"");
    XCTAssertTrue(objects.count == 3, @"");
}

- (void)testInsertsNewObjectsInInsertOrUpdateWithDifferingLocalAndRemoteUniqueKeys {
    NSArray *dictArray = @[@{@"remoteUniqueID" : @"123"}, @{@"remoteUniqueID" : @"456"}, @{@"remoteUniqueID" : @"789"}];
    NSError *insertOrUpdateError = nil;
    [Entity SQK_insertOrUpdate:dictArray
                uniqueModelKey:@"uniqueID"
               uniqueRemoteKey:@"remoteUniqueID"
           propertySetterBlock:nil
                privateContext:self.privateContext
                         error:&insertOrUpdateError];
    
    XCTAssertNil(insertOrUpdateError, @"");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.mainContext]];
    NSError *fetchError;
    NSArray *objects = [self.privateContext executeFetchRequest:request error:&fetchError];
    XCTAssertNil(fetchError, @"");
    XCTAssertTrue(objects.count == 3, @"");

}

- (void)testUpdatesExistingObjectsWithSameLocalAndRemoteKeys {
    Entity *existingEntity = [Entity SQK_insertInContext:self.privateContext];
    existingEntity.uniqueID = @"123";
    existingEntity.title = @"existing";
    
    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary* dictionary, Entity *entity) {
        entity.title = dictionary[@"title"];
    };
    
    NSArray *dictArray =@[
                          @{@"uniqueID" : @"123", @"title" : @"updated"},
                          @{@"uniqueID" : @"456", @"title" : @"abc"},
                          @{@"uniqueID" : @"789", @"title" : @"def"}
                          ];
    NSError *insertOrUpdateError = nil;
    [Entity SQK_insertOrUpdate:dictArray
                uniqueModelKey:@"uniqueID"
               uniqueRemoteKey:@"uniqueID"
           propertySetterBlock:propertySetterBlock
                       privateContext:self.privateContext
                         error:&insertOrUpdateError];
    
    XCTAssertNil(insertOrUpdateError, @"");
    
    [self.privateContext refreshObject:existingEntity mergeChanges:YES];
    XCTAssertEqualObjects(existingEntity.title, @"updated", @"");
}

- (void)testUpdatesObjectsWithDifferingLocalAndRemoteUniqueKeys {
    Entity *existingEntity = [Entity SQK_insertInContext:self.privateContext];
    existingEntity.uniqueID = @"123";
    existingEntity.title = @"existing";
    
    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary* dictionary, Entity *entity) {
        entity.title = dictionary[@"title"];
    };
    
    NSArray *dictArray =@[
                          @{@"remoteUniqueID" : @"123", @"title" : @"updated"}
                          ];
    NSError *insertOrUpdateError = nil;
    [Entity SQK_insertOrUpdate:dictArray
                uniqueModelKey:@"uniqueID"
               uniqueRemoteKey:@"remoteUniqueID"
           propertySetterBlock:propertySetterBlock
                privateContext:self.privateContext
                         error:&insertOrUpdateError];
    
    XCTAssertNil(insertOrUpdateError, @"");
    
    [self.privateContext refreshObject:existingEntity mergeChanges:YES];
    XCTAssertEqualObjects(existingEntity.title, @"updated", @"");
}

- (void)testInsertOrUpdateFailsWithUnsupportedConcurencyTypeError {
    NSError *insertOrUpdateError = nil;
    [Entity SQK_insertOrUpdate:@[]
                uniqueModelKey:@"unusedKey"
               uniqueRemoteKey:@"unusedKey"
           propertySetterBlock:nil
                privateContext:self.mainContext
                         error:&insertOrUpdateError];
    
    XCTAssertNotNil(insertOrUpdateError, @"");
    XCTAssertEqualObjects(insertOrUpdateError.domain, SQKDataKitErrorDomain, @"");
    XCTAssertEqual(insertOrUpdateError.code, (NSInteger)SQKDataKitErrorUnsupportedQueueConcurencyType, @"");
} 

@end

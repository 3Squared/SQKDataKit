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
@end

@implementation NSManagedObjectTests

- (void)setUp {
    [super setUp];
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    SQKContextManager *contextManager = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType managedObjectModel:model];
    self.mainContext = [contextManager mainContext];
}

- (void)tearDown {
    [self deleteAllEntityObjects];
}

- (void)deleteAllEntityObjects {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:_mainContext]];
    // Only fetch the managedObjectID
    [request setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *entities = [_mainContext executeFetchRequest:request error:&error];
    if (error) {
        abort();
    }
    
    for (NSManagedObject *entity in entities) {
        [_mainContext deleteObject:entity];
    }
    
    error = nil;
    [_mainContext save:&error];
    if (error) {
        abort();
    }
}

- (void)testEntityName {
    XCTAssertEqualObjects([Entity SQK_entityName], @"Entity", @"");
}

- (void)testEntityDescriptionInContext {
    NSEntityDescription *entityDescription = [Entity SQK_entityDescriptionInContext:_mainContext];
    
    XCTAssertEqualObjects(entityDescription.name, @"Entity", @"");
}

- (void)testInsetsIntoContext {
    Entity *entity = [Entity SQK_insertInContext:_mainContext];
    XCTAssertNotNil(entity, @"");
    
    entity.uniqueID = @"1234";
    
    NSEntityDescription *entityDescription = [Entity SQK_entityDescriptionInContext:_mainContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *array = [_mainContext executeFetchRequest:fetchRequest error:&error];
    XCTAssertNil(error, @"");
    XCTAssertTrue(array.count == 1, @"");
    
    Entity *fetchedEntity = array[0];
    XCTAssertEqualObjects(fetchedEntity.uniqueID, @"1234", @"");
}

- (void)testFetchRequest {
    NSFetchRequest *fetchRequest = [Entity SQK_fetchRequest];
    XCTAssertNotNil(fetchRequest, @"");
    XCTAssertEqualObjects(fetchRequest.entityName, @"Entity", @"");
}

- (void)testInsertsNewEntityWhenUniqe {
    NSError *error = nil;
    Entity *entity = [Entity SQK_findOrInsertByKey:@"uniqueID" value:@"abcd" context:_mainContext error:&error];
    
    XCTAssertNil(error, @"");
    XCTAssertNotNil(entity, @"");
    XCTAssertEqualObjects(entity.uniqueID, @"abcd", @"");
}

- (void)testFindsExistingWhenNotUnique {
    Entity *existingEntity = [Entity SQK_insertInContext:_mainContext];
    existingEntity.uniqueID = @"wxyz";
    
    NSError *error = nil;
    Entity *newEntity = [Entity SQK_findOrInsertByKey:@"uniqueID" value:@"wxyz" context:_mainContext error:&error];
    XCTAssertNil(error, @"");
    XCTAssertNotNil(newEntity, @"");
    XCTAssertEqualObjects(newEntity.uniqueID, @"wxyz", @"");
    XCTAssertEqualObjects(newEntity.objectID, existingEntity.objectID, @"");
}

- (void)testDeletesObject {
    Entity *entity = [Entity SQK_insertInContext:_mainContext];
    id objectID = entity.objectID;
    
    [entity SQK_deleteObject];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:_mainContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"objectID == %@", objectID]];
    NSError *error;
    NSArray *objects = [_mainContext executeFetchRequest:request error:&error];
    XCTAssertNil(error, @"");
    XCTAssertTrue(objects.count == 0, @"");
}

- (void)testDeleteAllObjectsInContext {
    for (NSInteger i = 0; i < 10; ++i) {
        [Entity SQK_insertInContext:_mainContext];
    }
    
    NSError *deleteError = nil;
    [Entity SQK_deleteAllObjectsInContext:_mainContext error:&deleteError];
    XCTAssertNil(deleteError, @"");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:_mainContext]];
    
    NSError *fetchError = nil;
    NSArray *objects = [_mainContext executeFetchRequest:request error:&fetchError];
    XCTAssertNil(fetchError, @"");
    XCTAssertEqual((NSInteger)objects.count, (NSInteger)0, @"");
}

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
                       context:_mainContext
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
                       context:_mainContext
                         error:&error];
    
    XCTAssertNil(error, @"");
    XCTAssertEqual(capturedDictionary, propertyDictionary, @"");
    XCTAssertTrue([capturedManagedObject isKindOfClass:[Entity class]], @"");
}

- (void)testInsertsAllNewObjectsInInsertOrUpdate {
    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary* dictionary, Entity *entity) {
        entity.uniqueID = dictionary[@"uniqueID"];
    };
    
    NSArray *dictArray = @[@{@"uniqueID" : @"123"}, @{@"uniqueID" : @"456"}, @{@"uniqueID" : @"789"}];
    NSError *insertOrUpdateError = nil;
    [Entity SQK_insertOrUpdate:dictArray
                uniqueModelKey:@"uniqueID"
               uniqueRemoteKey:@"uniqueID"
           propertySetterBlock:propertySetterBlock
                       context:_mainContext
                         error:&insertOrUpdateError];
    
    XCTAssertNil(insertOrUpdateError, @"");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Entity" inManagedObjectContext:_mainContext]];
    NSError *fetchError;
    NSArray *objects = [_mainContext executeFetchRequest:request error:&fetchError];
    XCTAssertNil(fetchError, @"");
    XCTAssertTrue(objects.count == 3, @"");
}

- (void)testUpdatesExistingObjects {
    Entity *existingEntity = [Entity SQK_insertInContext:_mainContext];
    existingEntity.uniqueID = @"123";
    existingEntity.title = @"existing";
    
    SQKPropertySetterBlock propertySetterBlock = ^void(NSDictionary* dictionary, Entity *entity) {
        entity.uniqueID = dictionary[@"uniqueID"];
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
                       context:_mainContext
                         error:&insertOrUpdateError];
    
    XCTAssertNil(insertOrUpdateError, @"");
    
    [_mainContext refreshObject:existingEntity mergeChanges:YES];
    XCTAssertEqualObjects(existingEntity.title, @"updated", @"");
}


@end

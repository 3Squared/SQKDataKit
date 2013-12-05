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
    SQKContextManager *contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType managedObjectModel:model];
    self.mainContext = [contextManager mainContext];
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
    
    NSError *error;
    NSArray *array = [_mainContext executeFetchRequest:fetchRequest error:&error];
    XCTAssertNil(error, @"");
    XCTAssertTrue(array.count == 1, @"");
    
    Entity *fetchedEntity = array[0];
    XCTAssertEqualObjects(fetchedEntity.uniqueID, @"1234", @"");

}

@end

//
//  NSPersistentStoreCoordinator+SQKExtensionsTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSPersistentStoreCoordinator+SQKExtensions.h"
#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator_SQKExtensionsTests : XCTestCase
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@end

@implementation NSPersistentStoreCoordinator_SQKExtensionsTests

- (void)setUp {
    [super setUp];
    _managedObjectModel = [[NSManagedObjectModel alloc] init];
}

- (void)testCorrectManagedObjectModel {
    NSPersistentStoreCoordinator *storeCoordincator = [NSPersistentStoreCoordinator SQK_storeCoordinatorWithManagedObjectModel:_managedObjectModel storeType:NSSQLiteStoreType];
    XCTAssertNotNil(storeCoordincator, @"");
    XCTAssertEqualObjects(storeCoordincator.managedObjectModel, _managedObjectModel, @"");
}

- (void)testHasOnePersistentStoreWithCorrectStoreType {
    
    NSPersistentStoreCoordinator *storeCoordincator = [NSPersistentStoreCoordinator SQK_storeCoordinatorWithManagedObjectModel:_managedObjectModel storeType:NSSQLiteStoreType];
    
    XCTAssertNotNil(storeCoordincator, @"");
    XCTAssertTrue([storeCoordincator persistentStores].count == 1, @"");
}

- (void)testCorrectStoreType {
    NSPersistentStoreCoordinator *storeCoordincator = [NSPersistentStoreCoordinator SQK_storeCoordinatorWithManagedObjectModel:_managedObjectModel storeType:NSSQLiteStoreType];
    
    NSPersistentStore *store = (NSPersistentStore *)[storeCoordincator persistentStores][0];
    XCTAssertEqualObjects(store.type, NSSQLiteStoreType, @"");
}

- (void)testCorrectStoreOptions {
    NSPersistentStoreCoordinator *storeCoordincator = [NSPersistentStoreCoordinator SQK_storeCoordinatorWithManagedObjectModel:_managedObjectModel storeType:NSSQLiteStoreType];
    
    NSPersistentStore *store = (NSPersistentStore *)[storeCoordincator persistentStores][0];
    XCTAssertEqualObjects(store.options[NSMigratePersistentStoresAutomaticallyOption], @(YES), @"");
    XCTAssertEqualObjects(store.options[NSInferMappingModelAutomaticallyOption], @(YES), @"");
}



@end

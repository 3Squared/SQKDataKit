//
//  NSPersistentStoreCoordinator+SQKExtensionsTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSPersistentStoreCoordinator+SQKAdditions.h"
#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinatorTests : XCTestCase
@property (nonatomic, strong) NSPersistentStoreCoordinator *persitentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@end

@implementation NSPersistentStoreCoordinatorTests

- (void)setUp
{
    [super setUp];
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    self.persitentStoreCoordinator =
        [NSPersistentStoreCoordinator sqk_storeCoordinatorWithStoreType:NSSQLiteStoreType
                                                     managedObjectModel:self.managedObjectModel
                                                               storeURL:nil];
}

- (void)testCorrectManagedObjectModel
{
    XCTAssertNotNil(self.persitentStoreCoordinator, @"");
    XCTAssertEqualObjects(self.persitentStoreCoordinator.managedObjectModel, _managedObjectModel, @"");
}

- (void)testHasOnePersistentStore
{
    XCTAssertNotNil(self.persitentStoreCoordinator, @"");
    XCTAssertTrue([self.persitentStoreCoordinator persistentStores].count == 1, @"");
}

- (void)testCorrectStoreType
{
    NSPersistentStore *store = (NSPersistentStore *)[self.persitentStoreCoordinator persistentStores][0];
    XCTAssertEqualObjects(store.type, NSSQLiteStoreType, @"");
}

- (void)testCorrectStoreOptions
{
    NSPersistentStore *store = (NSPersistentStore *)[self.persitentStoreCoordinator persistentStores][0];
    XCTAssertEqualObjects(store.options[NSMigratePersistentStoresAutomaticallyOption], @(YES), @"");
    XCTAssertEqualObjects(store.options[NSInferMappingModelAutomaticallyOption], @(YES), @"");
}


@end

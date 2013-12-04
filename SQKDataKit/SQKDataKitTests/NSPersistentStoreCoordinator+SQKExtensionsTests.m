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

@end

@implementation NSPersistentStoreCoordinator_SQKExtensionsTests

- (void)testCorrectManagedObjectModel {
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] init];
    NSPersistentStoreCoordinator *storeCoordincator = [NSPersistentStoreCoordinator SQK_storeCoordinatorWithManagedObjectModel:managedObjectModel];
    XCTAssertNotNil(storeCoordincator, @"");
    XCTAssertEqualObjects(storeCoordincator.managedObjectModel, managedObjectModel, @"");
}

- (void)testHasOnePersistentStore {
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] init];
    NSPersistentStoreCoordinator *storeCoordincator = [NSPersistentStoreCoordinator SQK_storeCoordinatorWithManagedObjectModel:managedObjectModel];
    XCTAssertNotNil(storeCoordincator, @"");
    XCTAssertTrue([storeCoordincator persistentStores].count == 1, @"");
}

@end

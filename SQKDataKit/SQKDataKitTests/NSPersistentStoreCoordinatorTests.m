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
// sut is the "System Under Test"
@property (nonatomic, strong) NSPersistentStoreCoordinator *sut;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@end

@implementation NSPersistentStoreCoordinatorTests

- (void)setUp {
    [super setUp];
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    self.sut = [NSPersistentStoreCoordinator SQK_storeCoordinatorWithStoreType:NSSQLiteStoreType managedObjectModel:self.managedObjectModel];
}

- (void)testCorrectManagedObjectModel {
    XCTAssertNotNil(self.sut, @"");
    XCTAssertEqualObjects(self.sut.managedObjectModel, _managedObjectModel, @"");
}

- (void)testHasOnePersistentStoreWithCorrectStoreType {
    XCTAssertNotNil(self.sut, @"");
    XCTAssertTrue([self.sut persistentStores].count == 1, @"");
}

- (void)testCorrectStoreType {
    NSPersistentStore *store = (NSPersistentStore *)[self.sut persistentStores][0];
    XCTAssertEqualObjects(store.type, NSSQLiteStoreType, @"");
}

- (void)testCorrectStoreOptions {
    NSPersistentStore *store = (NSPersistentStore *)[self.sut persistentStores][0];
    XCTAssertEqualObjects(store.options[NSMigratePersistentStoresAutomaticallyOption], @(YES), @"");
    XCTAssertEqualObjects(store.options[NSInferMappingModelAutomaticallyOption], @(YES), @"");
}



@end

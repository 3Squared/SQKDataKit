//
//  SQKContextManagerTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQKContextManager.h"

@interface SQKContextManagerTests : XCTestCase
// sut is the "System Under Tets"
@property (nonatomic, retain) SQKContextManager *sut;
@end

@implementation SQKContextManagerTests

#pragma mark - Initialisation

- (void)testInitialisesWithDefaultStoreType {
    _sut = [[SQKContextManager alloc] init];
    XCTAssertNotNil(_sut, @"");
    XCTAssertEqualObjects(_sut.storeType, NSSQLiteStoreType, @"");
}

- (void)testInitialisesWithAStoreType {
    _sut = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType];
    XCTAssertNotNil(_sut, @"");
    XCTAssertEqualObjects(_sut.storeType, NSSQLiteStoreType, @"");
}

- (void)testInitialisesWithDefaultStoreTypeWhenNilStoreTypeSpecified {
    _sut = [[SQKContextManager alloc] initWithStoreType:nil];
    XCTAssertNotNil(_sut, @"");
    XCTAssertEqualObjects(_sut.storeType, NSSQLiteStoreType, @"");
}

- (void)testInitialisesWithStoreTypeAndMangedObjectModel {
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] init];
    _sut = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType managedObjectModel:managedObjectModel];
    XCTAssertNotNil(_sut, @"");
    XCTAssertEqualObjects(_sut.storeType, NSSQLiteStoreType, @"");
    XCTAssertEqualObjects(_sut.managedObjectModel, managedObjectModel, @"");
}


#pragma mark - Contexts

- (void)testProvidesMainContext {
    _sut = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType];
    XCTAssertNotNil([_sut mainContext], @"");
}

- (void)testProvidesSameMainContext {
    _sut = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType];
    NSManagedObjectContext *firstContext = [_sut mainContext];
    NSManagedObjectContext *secondContext = [_sut mainContext];
    XCTAssertEqualObjects(firstContext, secondContext, @"");
}

- (void)testProvidesANewPrivateContext {
    _sut = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType];
    NSManagedObjectContext *privateContext = [_sut newPrivateContext];
    XCTAssertNotNil(privateContext, @"");
    XCTAssertEqual((NSInteger)privateContext.concurrencyType, (NSInteger)NSPrivateQueueConcurrencyType, @"");
}


@end

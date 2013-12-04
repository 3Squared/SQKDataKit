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
@property (nonatomic, retain) SQKContextManager *sut;
@end

@implementation SQKContextManagerTests

- (void)tearDown {
    [super tearDown];
    _sut = nil;
}

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


@end

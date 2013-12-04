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

- (void)testInitialisesWithAStoreType {
    _sut = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType];
    XCTAssertNotNil(_sut, @"");
    XCTAssertEqualObjects(_sut.storeType, NSSQLiteStoreType, @"");
}

- (void)testInitialisesWithDefaultStoreType {
    _sut = [[SQKContextManager alloc] init];
    XCTAssertNotNil(_sut, @"");
    XCTAssertEqualObjects(_sut.storeType, NSSQLiteStoreType, @"");
}

@end

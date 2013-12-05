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

@interface TestEntity : NSManagedObject
@end
@implementation TestEntity
@end

@interface NSManagedObjectTests : XCTestCase

@end

@implementation NSManagedObjectTests

- (void)testEntityName {
    XCTAssertEqualObjects([TestEntity SQK_entityName], @"TestEntity", @"");
}

@end

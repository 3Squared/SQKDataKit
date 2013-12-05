//
//  SQKContextManagerTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SQKContextManager.h"

@interface SQKContextManagerTests : XCTestCase
// sut is the "System Under Tets"
@property (nonatomic, retain) SQKContextManager *sut;
@property (nonatomic, retain) id mockMainContextWithChanges;
@property (nonatomic, retain) id mockMainContextWithoutChanges;
@end

@implementation SQKContextManagerTests

#pragma mark - Helpers

- (id)mockMainContextWithChanges {
    if (!_mockMainContextWithChanges) {
        _mockMainContextWithChanges = [self mockMainContextWithHasChangesBoolean:YES];
    }
    return _mockMainContextWithChanges;
}

- (id)mockMainContextWithoutChanges {
    if (!_mockMainContextWithoutChanges) {
        _mockMainContextWithoutChanges = [self mockMainContextWithHasChangesBoolean:NO];
    }
    return _mockMainContextWithoutChanges;
}

- (id)mockMainContextWithHasChangesBoolean:(BOOL)hasChanges {
    id mock = [OCMockObject mockForClass:[NSManagedObjectContext class]];
    [[[mock stub] andReturnValue:OCMOCK_VALUE(hasChanges)] hasChanges];
    return mock;
}

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


#pragma mark - Saving

- (void)testSavesWhenThereAreChanges {
    _sut = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType];
    id sutMock = [OCMockObject partialMockForObject:_sut];
    [[[sutMock stub] andCall:@selector(mockMainContextWithChanges) onObject:self] mainContext];
    
    [[self.mockMainContextWithChanges expect] save:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    
    NSError *saveError = nil;
    BOOL didSave = [sutMock saveMainContext:&saveError];
    
    XCTAssertTrue(didSave, @"");
    [self.mockMainContextWithChanges verify];
}

- (void)testDoesNotSaveWhenNoChanges {
    _sut = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType];
    id sutMock = [OCMockObject partialMockForObject:_sut];
    [[[sutMock stub] andCall:@selector(mockMainContextWithoutChanges) onObject:self] mainContext];
    
    [[self.mockMainContextWithoutChanges reject] save:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    
    NSError *saveError = nil;
    BOOL didSave = [sutMock saveMainContext:&saveError];
    
    XCTAssertFalse(didSave, @"");
    [self.mockMainContextWithoutChanges verify];
}


@end

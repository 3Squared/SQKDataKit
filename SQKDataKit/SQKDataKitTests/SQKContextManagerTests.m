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
// sut is the "System Under Test"
@property (nonatomic, retain) SQKContextManager *sut;
@property (nonatomic, retain) id mockMainContextWithChanges;
@property (nonatomic, retain) id mockMainContextWithoutChanges;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@end

@implementation SQKContextManagerTests


- (void)setUp {
    [super setUp];
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
    self.sut = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType managedObjectModel:self.managedObjectModel];
}


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

- (void)testInitialisesWithAStoreTypeAndMangedObjectModel {
    _sut = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType managedObjectModel:self.managedObjectModel];
    XCTAssertNotNil(_sut, @"");
    XCTAssertEqualObjects(_sut.storeType, NSInMemoryStoreType, @"");
    XCTAssertEqualObjects(_sut.managedObjectModel, self.managedObjectModel, @"");
}

- (void)testReturnsNilWithNoStoreType {
    _sut = [[SQKContextManager alloc] initWithStoreType:nil managedObjectModel:self.managedObjectModel];
    XCTAssertNil(_sut, @"");
}

- (void)testReturnsNilWithNoManagedObjectModel {
    _sut = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType managedObjectModel:nil];
    XCTAssertNil(_sut, @"");
}

- (void)testReturnsNilWhenUsingIncorrectStoreTypeString {
    _sut = [[SQKContextManager alloc] initWithStoreType:@"unsupported" managedObjectModel:self.managedObjectModel];
    XCTAssertNil(_sut, @"");
}

#pragma mark - Contexts

- (void)testProvidesMainContext {
    XCTAssertNotNil([_sut mainContext], @"");
}

- (void)testProvidesSameMainContext {
    NSManagedObjectContext *firstContext = [_sut mainContext];
    NSManagedObjectContext *secondContext = [_sut mainContext];
    XCTAssertEqualObjects(firstContext, secondContext, @"");
}

- (void)testProvidesANewPrivateContext {
    NSManagedObjectContext *privateContext = [_sut newPrivateContext];
    XCTAssertNotNil(privateContext, @"");
    XCTAssertEqual((NSInteger)privateContext.concurrencyType, (NSInteger)NSPrivateQueueConcurrencyType, @"");
}

- (void)testMainContextAndPrivateContextUseSamePersitentStoreCoordinator {
    NSManagedObjectContext *mainContext = [_sut mainContext];
    NSManagedObjectContext *privateContext = [_sut newPrivateContext];
    XCTAssertEqualObjects(mainContext.persistentStoreCoordinator, privateContext.persistentStoreCoordinator, @"");
}

- (void)testMainContextHasAStoreCoordinator {
    XCTAssertNotNil([_sut mainContext].persistentStoreCoordinator, @"");
}

- (void)testPrivateContextHasAStoreCoordinator {
    XCTAssertNotNil([_sut newPrivateContext].persistentStoreCoordinator, @"");
}

- (void)testStoreCoordinatorHasASingleStore {
    XCTAssertTrue([_sut mainContext].persistentStoreCoordinator.persistentStores.count == 1, @"");
}

#pragma mark - Saving

- (void)testSavesWhenThereAreChanges {
    id sutMock = [OCMockObject partialMockForObject:_sut];
    [[[sutMock stub] andCall:@selector(mockMainContextWithChanges) onObject:self] mainContext];
    
    [[self.mockMainContextWithChanges expect] save:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    
    NSError *saveError = nil;
    BOOL didSave = [sutMock saveMainContext:&saveError];
    
    XCTAssertTrue(didSave, @"");
    [self.mockMainContextWithChanges verify];
}

- (void)testDoesNotSaveWhenNoChanges {
    id sutMock = [OCMockObject partialMockForObject:_sut];
    [[[sutMock stub] andCall:@selector(mockMainContextWithoutChanges) onObject:self] mainContext];
    
    [[self.mockMainContextWithoutChanges reject] save:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    
    NSError *saveError = nil;
    BOOL didSave = [sutMock saveMainContext:&saveError];
    
    XCTAssertFalse(didSave, @"");
    [self.mockMainContextWithoutChanges verify];
}


@end

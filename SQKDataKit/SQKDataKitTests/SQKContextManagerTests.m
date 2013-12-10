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

/**
 *  Category that redefines the private internals of SQKContextManager
 *  so we can access the properties necessary for testing.
 */
@interface SQKContextManager (TestVisibility)
@property (nonatomic, strong, readwrite) NSManagedObjectContext* mainContext;
@end

@interface SQKContextManagerTests : XCTestCase
// sut is the "System Under Test"
@property (nonatomic, retain) SQKContextManager *sut;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@end

@implementation SQKContextManagerTests

- (void)setUp {
    [super setUp];
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
    self.sut = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType managedObjectModel:self.managedObjectModel];
}


#pragma mark - Helpers

- (id)mockMainContextWithStubbedHasChangesReturnValue:(BOOL)hasChanges {
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
    id contextWithChanges = [self mockMainContextWithStubbedHasChangesReturnValue:YES];
    self.sut.mainContext = contextWithChanges;
    
    [[contextWithChanges expect] save:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    
    NSError *saveError = nil;
    BOOL didSave = [self.sut saveMainContext:&saveError];
    
    XCTAssertTrue(didSave, @"");
    [contextWithChanges verify];
}

- (void)testDoesNotSaveWhenNoChanges {
    id contextWithoutChanges = [self mockMainContextWithStubbedHasChangesReturnValue:NO];
    self.sut.mainContext = contextWithoutChanges;
    
    [[contextWithoutChanges reject] save:(NSError * __autoreleasing *)[OCMArg anyPointer]];

    NSError *saveError = nil;
    BOOL didSave = [self.sut saveMainContext:&saveError];
    
    XCTAssertFalse(didSave, @"");
    [contextWithoutChanges verify];
}


@end

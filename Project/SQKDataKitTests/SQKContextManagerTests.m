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
    self.sut = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType managedObjectModel:self.managedObjectModel];
    XCTAssertNotNil(self.sut, @"");
    XCTAssertEqualObjects(self.sut.storeType, NSInMemoryStoreType, @"");
    XCTAssertEqualObjects(self.sut.managedObjectModel, self.managedObjectModel, @"");
}

- (void)testReturnsNilWithNoStoreType {
    self.sut = [[SQKContextManager alloc] initWithStoreType:nil managedObjectModel:self.managedObjectModel];
    XCTAssertNil(self.sut, @"");
}

- (void)testReturnsNilWithNoManagedObjectModel {
    self.sut = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType managedObjectModel:nil];
    XCTAssertNil(self.sut, @"");
}

- (void)testReturnsNilWhenUsingIncorrectStoreTypeString {
    self.sut = [[SQKContextManager alloc] initWithStoreType:@"unsupported" managedObjectModel:self.managedObjectModel];
    XCTAssertNil(self.sut, @"");
}

#pragma mark - Contexts

- (void)testProvidesMainContext {
    XCTAssertNotNil([self.sut mainContext], @"");
}

- (void)testProvidesSameMainContext {
    NSManagedObjectContext *firstContext = [self.sut mainContext];
    NSManagedObjectContext *secondContext = [self.sut mainContext];
    XCTAssertEqualObjects(firstContext, secondContext, @"");
}

- (void)testProvidesANewPrivateContext {
    NSManagedObjectContext *privateContext = [self.sut newPrivateContext];
    XCTAssertNotNil(privateContext, @"");
    XCTAssertEqual((NSInteger)privateContext.concurrencyType, (NSInteger)NSPrivateQueueConcurrencyType, @"");
}

- (void)testMainContextAndPrivateContextUseSamePersistentStoreCoordinator {
    NSManagedObjectContext *mainContext = [self.sut mainContext];
    NSManagedObjectContext *privateContext = [self.sut newPrivateContext];
    XCTAssertEqualObjects(mainContext.persistentStoreCoordinator, privateContext.persistentStoreCoordinator, @"");
}

- (void)testMainContextHasAStoreCoordinator {
    XCTAssertNotNil([self.sut mainContext].persistentStoreCoordinator, @"");
}

- (void)testPrivateContextHasAStoreCoordinator {
    XCTAssertNotNil([self.sut newPrivateContext].persistentStoreCoordinator, @"");
}

- (void)testStoreCoordinatorHasASingleStore {
    XCTAssertTrue([self.sut mainContext].persistentStoreCoordinator.persistentStores.count == 1, @"");
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

- (void)testDoesNotSaveWhenThrereAreNoChanges {
    id contextWithoutChanges = [self mockMainContextWithStubbedHasChangesReturnValue:NO];
    self.sut.mainContext = contextWithoutChanges;
    
    [[contextWithoutChanges reject] save:(NSError * __autoreleasing *)[OCMArg anyPointer]];

    NSError *saveError = nil;
    BOOL didSave = [self.sut saveMainContext:&saveError];
    
    XCTAssertFalse(didSave, @"");
    [contextWithoutChanges verify];
}


@end

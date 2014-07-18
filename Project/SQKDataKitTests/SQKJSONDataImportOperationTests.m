//
//  SQKJSONDataImportOperationTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SQKCoreDataOperation.h"
#import "SQKContextManager.h"

@interface ConcreteDataImportOperationWithoutOverride : SQKCoreDataOperation
@end
@implementation ConcreteDataImportOperationWithoutOverride
@end

@interface ConcreteDataImportOperation : SQKCoreDataOperation
@end
@implementation ConcreteDataImportOperation
- (void)performWorkPrivateContext:(NSManagedObjectContext *)context
{
}
@end

@interface SQKJSONDataImportOperationTests : XCTestCase
@property (nonatomic, strong) SQKContextManager *contextManager;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation SQKJSONDataImportOperationTests

- (void)setUp
{
    [super setUp];
    NSManagedObjectModel *managedObjectModel =
        [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                    managedObjectModel:managedObjectModel
                                                              storeURL:nil];
    self.context = [self.contextManager newPrivateContext];
}

- (void)testInitialisesWithContextAndJSON
{
    SQKCoreDataOperation *dataImportOperation =
        [[SQKCoreDataOperation alloc] initWithContextManager:self.contextManager];

    XCTAssertNotNil(dataImportOperation, @"");
}

- (void)testStoresConstructorParametersInProperties
{
    SQKCoreDataOperation *dataImportOperation =
        [[SQKCoreDataOperation alloc] initWithContextManager:self.contextManager];

    XCTAssertEqual(dataImportOperation.contextManager, self.contextManager, @"");
}

- (void)testThrowsExpectionIfUpdateMethodNotOverridden
{
    ConcreteDataImportOperationWithoutOverride *dataImportOperation =
        [[ConcreteDataImportOperationWithoutOverride alloc] initWithContextManager:self.contextManager];
    XCTAssertThrowsSpecificNamed([dataImportOperation performWorkPrivateContext:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
}

- (void)testCallsUpdateWhenOperationIsStarted
{
    ConcreteDataImportOperation *dataImportOperation =
        [[ConcreteDataImportOperation alloc] initWithContextManager:self.contextManager];
    id dataImportOperationPartialMock = [OCMockObject partialMockForObject:dataImportOperation];
    [[dataImportOperationPartialMock expect] performWorkPrivateContext:[OCMArg any]];

    [(ConcreteDataImportOperation *)dataImportOperationPartialMock start];

    [dataImportOperationPartialMock verify];
}

@end

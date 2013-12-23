//
//  SQKJSONDataImportOperationTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SQKDataImportOperation.h"
#import "SQKContextManager.h"

@interface ConcreteDataImportOperationWithoutOverride : SQKDataImportOperation
@end
@implementation ConcreteDataImportOperationWithoutOverride
@end

@interface ConcreteDataImportOperation : SQKDataImportOperation
@end
@implementation ConcreteDataImportOperation
- (void)updateContext:(NSManagedObjectContext *)context usingData:(id)data {
}
@end

@interface SQKJSONDataImportOperationTests : XCTestCase
@property (nonatomic, strong) SQKContextManager *contextManager;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation SQKJSONDataImportOperationTests

- (void)setUp {
    [super setUp];
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType managedObjectModel:managedObjectModel];
    self.context = [self.contextManager newPrivateContext];
}

- (void)testInitialisesWithContextAndJSON {
    NSDictionary *json = @{};
    SQKDataImportOperation *dataImportOperation = [[SQKDataImportOperation alloc] initWithContextManager:self.contextManager data:json];
    
    XCTAssertNotNil(dataImportOperation, @"");
}

- (void)testStoresConstructorParametersInProperties {
    NSDictionary *json = @{};
    SQKDataImportOperation *dataImportOperation = [[SQKDataImportOperation alloc] initWithContextManager:self.contextManager data:json];
    
    XCTAssertEqual(dataImportOperation.contextManager, self.contextManager, @"");
    XCTAssertEqual(dataImportOperation.data, json, @"");
}

- (void)testThrowsExpectionIfUpdateMethodNotOverridden {
    ConcreteDataImportOperationWithoutOverride *dataImportOperation = [[ConcreteDataImportOperationWithoutOverride alloc] initWithContextManager:self.contextManager data:@{}];
    XCTAssertThrowsSpecificNamed([dataImportOperation updatePrivateContext:self.context usingData:@{}], NSException, NSInternalInconsistencyException, @"");
}

- (void)testCallsUpdateWhenOperationIsStarted {
    id json = @{@"key" : @"value"};
    
    ConcreteDataImportOperation *dataImportOperation = [[ConcreteDataImportOperation alloc] initWithContextManager:self.contextManager data:json];
    id dataImportOperationPartialMock = [OCMockObject partialMockForObject:dataImportOperation];
    [[dataImportOperationPartialMock expect] updateContext:[OCMArg any] usingData:json];
    
    [(ConcreteDataImportOperation *)dataImportOperationPartialMock start];
    
    [dataImportOperationPartialMock verify];
}

@end

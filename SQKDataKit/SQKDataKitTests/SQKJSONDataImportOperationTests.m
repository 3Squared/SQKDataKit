//
//  SQKJSONDataImportOperationTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SQKJSONDataImportOperation.h"
#import "SQKContextManager.h"

@interface ConcreteDataImportOperationWithouOveride : SQKJSONDataImportOperation
@end
@implementation ConcreteDataImportOperationWithouOveride
@end

@interface ConcreteDataImportOperation : SQKJSONDataImportOperation
@end
@implementation ConcreteDataImportOperation
- (void)updatePrivateContext:(NSManagedObjectContext *)context usingJSON:(id)json {
}
@end

@interface SQKJSONDataImportOperationTests : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation SQKJSONDataImportOperationTests

- (void)setUp {
    [super setUp];
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
    SQKContextManager *contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType managedObjectModel:managedObjectModel];
    self.context = [contextManager newPrivateContext];
}

- (void)testInitialisesWithContextAndJSON {
    NSDictionary *json = @{};
    SQKJSONDataImportOperation *dataImportOperation = [[SQKJSONDataImportOperation alloc] initWithPrivateContext:self.context json:json];
    
    XCTAssertNotNil(dataImportOperation, @"");
}

- (void)testStoresConstructorParamtersInProperties {
    NSDictionary *json = @{};
    SQKJSONDataImportOperation *dataImportOperation = [[SQKJSONDataImportOperation alloc] initWithPrivateContext:self.context json:json];
    
    XCTAssertEqual(dataImportOperation.privateContext, self.context, @"");
    XCTAssertEqual(dataImportOperation.json, json, @"");
}

- (void)testThrowsExpectionIfUpdateMethodNotOverridden {
    ConcreteDataImportOperationWithouOveride *dataImportOperation = [[ConcreteDataImportOperationWithouOveride alloc] initWithPrivateContext:self.context json:@{}];
    XCTAssertThrowsSpecificNamed([dataImportOperation updatePrivateContext:self.context usingJSON:@{}], NSException, NSInternalInconsistencyException, @"");
}

- (void)testCallsUpdateWhenOperationIsStarted {
    id json = @{@"key" : @"value"};
    
    ConcreteDataImportOperation *dataImportOperation = [[ConcreteDataImportOperation alloc] initWithPrivateContext:self.context json:json];
    id dataImportOperationPartialMock = [OCMockObject partialMockForObject:dataImportOperation];
    [[dataImportOperationPartialMock expect] updatePrivateContext:self.context usingJSON:json];
    
    [(ConcreteDataImportOperation *)dataImportOperationPartialMock start];
    
    [dataImportOperationPartialMock verify];
}

@end

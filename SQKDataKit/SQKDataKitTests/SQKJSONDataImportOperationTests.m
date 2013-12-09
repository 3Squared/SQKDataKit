//
//  SQKJSONDataImportOperationTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQKJSONDataImportOperation.h"
#import "SQKContextManager.h"

@interface ConcreteDataImportOperationWithouOveride : SQKJSONDataImportOperation
@end
@implementation ConcreteDataImportOperationWithouOveride
@end

@interface ConcreteDataImportOperation : SQKJSONDataImportOperation
@end
@implementation ConcreteDataImportOperation
@end

@interface SQKJSONDataImportOperationTests : XCTestCase
@property (nonatomic, strong) SQKJSONDataImportOperation *sut;
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
    self.sut = [[SQKJSONDataImportOperation alloc] initWithPrivateContext:self.context json:json];
    
    XCTAssertNotNil(self.sut, @"");
}

- (void)testStoresConstructorParamtersInProperties {
    NSDictionary *json = @{};
    self.sut = [[SQKJSONDataImportOperation alloc] initWithPrivateContext:self.context json:json];
    
    XCTAssertEqual(self.sut.privateContext, self.context, @"");
    XCTAssertEqual(self.sut.json, json, @"");
}

- (void)testThrowsExpectionIfUpdateMethodNotOverridden {
    ConcreteDataImportOperationWithouOveride *dataImportOperation = [[ConcreteDataImportOperationWithouOveride alloc] initWithPrivateContext:self.context json:@{}];
    XCTAssertThrowsSpecificNamed([dataImportOperation updatePrivateContext:self.context usingJSON:@{}], NSException, NSInternalInconsistencyException, @"");
}

@end

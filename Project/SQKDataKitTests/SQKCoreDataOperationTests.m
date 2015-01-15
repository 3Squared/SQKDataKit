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
#import "SQKDataKitErrors.h"

@interface ConcreteDataImportOperationWithoutOverride : SQKCoreDataOperation
@end
@implementation ConcreteDataImportOperationWithoutOverride
@end

@interface ConcreteDataImportOperation : SQKCoreDataOperation
@end
@implementation ConcreteDataImportOperation
- (void)performWorkWithPrivateContext:(NSManagedObjectContext *)context
{
}
@end

@interface ConcreteDataImportOperationWithErrors : SQKCoreDataOperation
@end
@implementation ConcreteDataImportOperationWithErrors
- (void)performWorkWithPrivateContext:(NSManagedObjectContext *)context
{
    [self addError:[NSError errorWithDomain:@"SQKCoreDataOperationTestsDomain" code:0 userInfo:nil]];
    [self addError:[NSError errorWithDomain:@"SQKCoreDataOperationTestsDomain" code:1 userInfo:nil]];
    [self addError:[NSError errorWithDomain:@"SQKCoreDataOperationTestsDomain" code:2 userInfo:@{ @"test" : @"hello world" }]];
}
@end

@interface SQKCoreDataOperationTests : XCTestCase
@property (nonatomic, strong) SQKContextManager *contextManager;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation SQKCoreDataOperationTests

- (void)setUp
{
    [super setUp];
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:@[ [NSBundle mainBundle] ]];
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                    managedObjectModel:managedObjectModel
                                        orderedManagedObjectModelNames:@[ @"SQKDataKitModel" ]
                                                              storeURL:nil];
    self.context = [self.contextManager newPrivateContext];
}

- (void)testInitialisesWithContextAndJSON
{
    SQKCoreDataOperation *dataImportOperation = [[SQKCoreDataOperation alloc] initWithContextManager:self.contextManager];

    XCTAssertNotNil(dataImportOperation, @"");
}

- (void)testStoresConstructorParametersInProperties
{
    SQKCoreDataOperation *dataImportOperation = [[SQKCoreDataOperation alloc] initWithContextManager:self.contextManager];

    XCTAssertEqual(dataImportOperation.contextManager, self.contextManager, @"");
}

- (void)testThrowsExpectionIfUpdateMethodNotOverridden
{
    ConcreteDataImportOperationWithoutOverride *dataImportOperation = [[ConcreteDataImportOperationWithoutOverride alloc] initWithContextManager:self.contextManager];
    XCTAssertThrowsSpecificNamed([dataImportOperation performWorkWithPrivateContext:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
}

- (void)testCallsUpdateWhenOperationIsStarted
{
    ConcreteDataImportOperation *dataImportOperation = [[ConcreteDataImportOperation alloc] initWithContextManager:self.contextManager];
    id dataImportOperationPartialMock = [OCMockObject partialMockForObject:dataImportOperation];
    [[dataImportOperationPartialMock expect] performWorkWithPrivateContext:[OCMArg any]];

    [(ConcreteDataImportOperation *)dataImportOperationPartialMock start];

    [dataImportOperationPartialMock verify];
}

- (void)testCombinesErrors
{
    ConcreteDataImportOperationWithErrors *dataImportOperation = [[ConcreteDataImportOperationWithErrors alloc] initWithContextManager:self.contextManager];
    [dataImportOperation start];

    NSError *error = [dataImportOperation error];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, SQKDataKitErrorDomain);
    XCTAssertEqual(error.code, (NSInteger)SQKDataKitOperationMultipleErrorsError);
    
    NSArray *subErrors = error.userInfo[NSDetailedErrorsKey];
    
    XCTAssertEqual(subErrors.count, 3);
    
    XCTAssertEqualObjects([[[subErrors lastObject] userInfo] objectForKey:@"test"], @"hello world");
}

@end

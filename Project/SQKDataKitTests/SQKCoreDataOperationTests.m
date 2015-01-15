//
//  SQKCoreDataOperationTests.m
//  SQKDataKit
//
//  Created by Luke Stringer on 02/09/2014.
//  Copyright (c) 2014 3Squared. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQKContextManager.h"
#import "SQKCoreDataOperation.h"
#import <AGAsyncTestHelper/AGAsyncTestHelper.h>
#import <OCMock/OCMock.h>

@interface SQKTestCoreDataOperation : SQKCoreDataOperation

@end

@implementation SQKTestCoreDataOperation

- (void)performWorkWithPrivateContext:(NSManagedObjectContext *)context {
    [self completeOperationBySavingContext:context];
}

@end

@interface SQKCoreDataOperationTests : XCTestCase
@property (nonatomic, retain) SQKContextManager *contextManager;
@property (nonatomic, retain) NSManagedObjectContext *mainContext;
@property (nonatomic, retain) NSOperationQueue *queue;
@end

@implementation SQKCoreDataOperationTests

- (void)setUp {
    [super setUp];
    NSManagedObjectModel *model= [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]];
    self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
                                                    managedObjectModel:model
                                        orderedManagedObjectModelNames:nil
                                                              storeURL:nil];
    self.mainContext = [self.contextManager mainContext];
    [self.mainContext reset];
    
    self.queue = [NSOperationQueue new];
}

- (void)testMergesIntoMainContextOnCompletion {
    SQKTestCoreDataOperation *operation = [[SQKTestCoreDataOperation alloc] initWithContextManager:self.contextManager];
    id mainContextPartialMock = [OCMockObject partialMockForObject:self.mainContext];
    [[mainContextPartialMock expect] mergeChangesFromContextDidSaveNotification:[OCMArg any]];
    
    __block bool operationDone = NO;
    [operation setCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            operationDone = YES;
            [mainContextPartialMock verify];
            [mainContextPartialMock stopMocking];
        }];
    }];
    
    [self.queue addOperation:operation];
    
    AGWW_WAIT_WHILE(!operationDone, 5.0);
}

@end

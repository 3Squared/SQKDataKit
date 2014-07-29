//
//  CDODataSychroniser.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "CDODataSynchroniser.h"
#import "SQKContextManager.h"
#import "SQKCoreDataOperation.h"
#import "CDOCommitImportOperation.h"
#import "CDOUserImportOperation.h"

@interface CDODataSynchroniser ()
@property (nonatomic, strong, readwrite) SQKContextManager *contextManager;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, assign, readwrite) BOOL isSynchronising;
@property (nonatomic, assign, readwrite) NSInteger pendingSyncs;
@property (nonatomic, strong) NSArray *synchroniseBlocks;
@property (nonatomic, assign) NSUInteger currentSynchroniseBlockIndex;
@end

@implementation CDODataSynchroniser

#pragma mark - Public

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager {
	if (self = [super init]) {
		self.contextManager = contextManager;
		self.operationQueue = [[NSOperationQueue alloc] init];
		self.isSynchronising = NO;
	}
	return self;
}

- (void)synchronise {
	++self.pendingSyncs;
	if (self.pendingSyncs == 1) {
		[self startSynchronise];
	}
}

#pragma mark - Starting and finishing syncrhonising

- (void)startSynchronise {
	NSLog(@"Starting Synchronise");
	self.isSynchronising = YES;

	// The synchronise work to do
	self.synchroniseBlocks = @[
	        ^{ [self synchroniseCommits]; },
	        ^{ [self synchroniseUsers]; },
	    ];
	self.currentSynchroniseBlockIndex = 0;

	[self executeNextSynchroniseBlock];
}

/**
 *  Executes the next block in self.synchroniseBlocks. If not more blocks then data sychronisation is finished.
 */
- (void)executeNextSynchroniseBlock {
	if (self.currentSynchroniseBlockIndex < self.synchroniseBlocks.count) {
		void (^syncBlock)(void) = self.synchroniseBlocks[self.currentSynchroniseBlockIndex];
		syncBlock();

		++self.currentSynchroniseBlockIndex;
	}
	else {
		[self setSynchroniseFinish];
	}
}

- (void)setSynchroniseFinish {
	[[NSOperationQueue mainQueue] addOperationWithBlock: ^{
	    NSLog(@"Finished Synchronise");
	    self.isSynchronising = NO;
	    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}];
}

- (BOOL)operationFinishedWithoutError:(SQKCoreDataOperation *)dataOperation {
	NSError *error = [dataOperation error];
	if (error) {
		[self setSynchroniseFinish];
		self.pendingSyncs = 0;
		return NO;
	}
	return YES;
}

#pragma mark - Synchronising methods

- (void)synchroniseCommits {
	CDOCommitImportOperation *operation = [[CDOCommitImportOperation alloc] initWithContextManager:self.contextManager];
	__weak typeof(CDOCommitImportOperation *) weakOperation = operation;

	[operation setCompletionBlock: ^{
	    CDOCommitImportOperation *strongOperation = weakOperation;
	    if ([self operationFinishedWithoutError:strongOperation]) {
	        [self executeNextSynchroniseBlock];
		}
	    else {
	        NSLog(@"Commit Import Error");
		}
	}];
	[self.operationQueue addOperation:operation];
}

- (void)synchroniseUsers {
	CDOUserImportOperation *operation = [[CDOUserImportOperation alloc] initWithContextManager:self.contextManager];
	__weak typeof(CDOUserImportOperation *) weakOperation = operation;

	[operation setCompletionBlock: ^{
	    CDOUserImportOperation *strongOperation = weakOperation;
	    if ([self operationFinishedWithoutError:strongOperation]) {
	        [self executeNextSynchroniseBlock];
		}
	    else {
	        NSLog(@"User Import Error");
		}
	}];
	[self.operationQueue addOperation:operation];
}

@end

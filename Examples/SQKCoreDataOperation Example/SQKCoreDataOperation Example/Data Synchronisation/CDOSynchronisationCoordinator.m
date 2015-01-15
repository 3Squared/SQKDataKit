//
//  CDODataSychroniser.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "CDOSynchronisationCoordinator.h"
#import "SQKContextManager.h"
#import "SQKCoreDataOperation.h"
#import "CDOCommitImportOperation.h"
#import "CDOUserImportOperation.h"
#import "CDONotificationManager.h"
#import "CDOGithubAPIClient.h"

NSString *const CDOSynchronisationRequestNotification = @"CDOSynchronisationRequestNotification";
NSString *const CDOSynchronisationResponseNotification = @"CDOSynchronisationResponseNotification";

@interface CDOSynchronisationCoordinator ()
@property (nonatomic, strong, readwrite) SQKContextManager *contextManager;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) CDOGithubAPIClient *APIClient;
@property (nonatomic, assign, readwrite) NSInteger pendingSyncs;
@end

@implementation CDOSynchronisationCoordinator

+ (void)synchronise
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CDOSynchronisationRequestNotification object:nil];
    }];
}

+ (void)finishSynchronise
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CDOSynchronisationResponseNotification object:nil];
    }];
}

#pragma mark - Public

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager APIClient:(CDOGithubAPIClient *)APIClient
{
    if (self = [super init])
    {
        self.contextManager = contextManager;
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:NULL];

        self.APIClient = APIClient;

        [CDONotificationManager addObserverForSynchronisationRequestNotification:self selector:@selector(synchronise)];
    }
    return self;
}

- (void)dealloc
{
    [CDONotificationManager removeObserverForSynchronisationRequestNotification:self];
}

- (void)synchronise
{
    ++self.pendingSyncs;
    if (self.pendingSyncs == 1)
    {
        [self startSynchronise];
    }
}

#pragma mark - Starting and finishing syncrhonising

- (void)startSynchronise
{
    NSLog(@"Starting Synchronise");

    CDOCommitImportOperation *commitOperation = [[CDOCommitImportOperation alloc] initWithContextManager:self.contextManager APIClient:self.APIClient];
    CDOUserImportOperation *userOperation = [[CDOUserImportOperation alloc] initWithContextManager:self.contextManager APIClient:self.APIClient];

    [userOperation addDependency:commitOperation];

    [self.operationQueue addOperation:commitOperation];
    [self.operationQueue addOperation:userOperation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    SQKCoreDataOperation *nextOperation = [[self.operationQueue operations] firstObject];
    for (SQKCoreDataOperation *dependentOperation in [nextOperation dependencies])
    {
        /**
		 *  Next operation to be executed should be cancelled if any of it's dependencies have
		 *  errored or were also cancelled. By cancelling the next operation we will also
		 *  also ensure that any of it's dependencies will also be canclled.
		 */
        if (dependentOperation.error || [dependentOperation isCancelled])
        {
            NSString *dependentOperationName = NSStringFromClass([dependentOperation class]);
            if (dependentOperation.error)
            {
                NSLog(@"Dependency \'%@\' errored; %@", dependentOperationName, dependentOperation.error);
            }
            if (dependentOperation.cancelled)
            {
                NSLog(@"Dependency \'%@\' cancelled", dependentOperationName);
            }
            [nextOperation cancel];
        }
    }

    if (object == self.operationQueue && self.operationQueue.operationCount == 0)
    {
        [self finishSynchronise];
    }
}

- (void)finishSynchronise
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
	    --self.pendingSyncs;
	    if (self.pendingSyncs > 0) {
	        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	        [self startSynchronise];
		}
	    else {
	        NSLog(@"Finished Synchronise");
	        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [CDOSynchronisationCoordinator finishSynchronise];
		}
    }];
}

@end

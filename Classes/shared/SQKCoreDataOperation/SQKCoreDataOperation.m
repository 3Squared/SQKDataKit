//
//  SQKCoreDataOperation.m
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKCoreDataOperation.h"
#import "SQKContextManager.h"
#import "NSManagedObjectContext+SQKAdditions.h"
#import "SQKDataKitErrors.h"

@interface SQKCoreDataOperation ()
@property (nonatomic, strong, readwrite) SQKContextManager *contextManager;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContextToMerge;
@property (nonatomic, assign) BOOL sqk_executing;
@property (nonatomic, assign) BOOL sqk_finished;
@property (nonatomic, strong) NSMutableArray *errors;
@end

@implementation SQKCoreDataOperation

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager
{
    self = [super init];
    if (self)
    {
        _contextManager = contextManager;
        _sqk_executing = NO;
        _sqk_finished = NO;
        _errors = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}

#pragma mark - To overrride

- (void)performWorkWithPrivateContext:(NSManagedObjectContext *)context
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - NSOperation

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        self.sqk_finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    self.sqk_executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    self.managedObjectContextToMerge = [self.contextManager newPrivateContext];
    
    // We are going to manage merging the context ourselves
    self.managedObjectContextToMerge.shouldMergeOnSave = NO;
    
    [self.managedObjectContextToMerge performBlockAndWait:^{
        [self performWorkWithPrivateContext:self.managedObjectContextToMerge];
    }];
}

- (BOOL)isConcurrent
{
    return [self isAsynchronous];
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isExecuting
{
    return self.sqk_executing;
}

- (BOOL)isFinished
{
    return self.sqk_finished;
}

#pragma mark - Completion

- (void)completeAndSave
{
    if ([self isCancelled])
    {
        [self finishOperation];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextSaveNotificationReceived:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
        
        NSError *error = nil;
        [self.managedObjectContextToMerge save:&error];
        if (error)
        {
            [self addError:error];
            [self finishOperation];
        }
    }
}

- (void)completeOperationBySavingContext:(NSManagedObjectContext *)managedObjectContext
{
    [self completeAndSave];
}

- (void)finishOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    self.sqk_executing = NO;
    self.sqk_finished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Errors

- (NSError *)error
{
    if (!self.errors || self.errors.count == 0)
    {
        return nil;
    }

    if ([self.errors count] == 1)
    {
        return [self.errors firstObject];
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

    [userInfo setObject:[NSArray arrayWithArray:self.errors] forKey:NSDetailedErrorsKey];

    return [NSError errorWithDomain:SQKDataKitErrorDomain code:SQKDataKitOperationMultipleErrorsError userInfo:userInfo];
}

- (void)addError:(NSError *)error
{
    if (error)
    {
        [self.errors addObject:error];
    }
}

#pragma mark - Merging

- (void)contextSaveNotificationReceived:(NSNotification *)notification
{
    NSManagedObjectContext *managedObjectContext = [notification object];
    if (managedObjectContext != self.managedObjectContextToMerge)
    {
        return;
    }
    
    // Ensure mainContext is accessed on the main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSManagedObjectContext *mainContext = self.contextManager.mainContext;
        [mainContext performBlock:^{
            
            [mainContext mergeChangesFromContextDidSaveNotification:notification];
            
            /**
             * This loop is needed for 'correct' behaviour of NSFetchedResultsControllers.
             *
             * NSManagedObjectContext doesn't event fire
             * NSManagedObjectContextObjectsDidChangeNotification for updated objects on merge,
             * only inserted.
             *
             * SEE:
             * http://stackoverflow.com/questions/3923826/nsfetchedresultscontroller-with-predicate-ignores-changes-merged-from-different
             *  May also have memory implications.
             */
            for (NSManagedObject *object in [[notification userInfo] objectForKey:NSUpdatedObjectsKey])
            {
                [[mainContext objectWithID:[object objectID]] willAccessValueForKey:nil];
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NSManagedObjectContextDidSaveNotification
                                                          object:nil];
            
            /**
             *  Note: we are now on the main thread when we finish the opreation.
             *  Not sure if finishing the operation (thus triggering the KVO notifications)
             *  on a different thread (main thread) to the operation's execution causes
             *  problems. Seems fine but might not be  ¯\_(ツ)_/¯
             */
            [self finishOperation];
        }];
    });
    
}

@end

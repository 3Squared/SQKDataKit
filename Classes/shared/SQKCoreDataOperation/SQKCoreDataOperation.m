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
    self.managedObjectContextToMerge.shouldMergeOnSave = YES;
    [self.managedObjectContextToMerge performBlockAndWait:^{
        [self performWorkWithPrivateContext:self.managedObjectContextToMerge];
    }];
}

- (BOOL)isConcurrent
{
    return NO;
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

- (void)completeOperationBySavingContext:(NSManagedObjectContext *)managedObjectContext
{
    if ([self isCancelled])
    {
        [self finishOperation];
    }
    else
    {
        self.managedObjectContextToMerge = managedObjectContext;
        
        [managedObjectContext performBlock:^{
            
            NSError *error = nil;
            [managedObjectContext save:&error];
            
            if (error)
            {
                [self addError:error];
            }
            [self finishOperation];
            
        }];
    }
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
	/**
	 *  Usually core data operartions do not happen on the main thread.
	 *  But as we are saving into the main context that must happen on the main thread.
	 *
	 *  This is done using GCD to ensure the block is performed on the main thread.
	 *  The issue is that once the private context has been merged into the main context, the core data
	 *  operation needs to call `finish` on the context for the operation.
	 *
	 *  To solve this semaphores can be used to halt the method until a notification is posted
	 *  to the semaphore.
	 */
	dispatch_semaphore_t mainContextSavedSemaphore = dispatch_semaphore_create(0);
	
	//Ensure mainContext is accessed on the main thread.
	dispatch_async(dispatch_get_main_queue(), ^{
		
		NSManagedObjectContext *mainContext = self.contextManager.mainContext;
		[mainContext performBlock:^{
			
			NSManagedObjectContext *managedObjectContext = [notification object];
			
			/**
			 *  If NSManagedObjectContext from the notitification is a private context
			 *	then merge the changes into the main context.
			 */
			if (managedObjectContext == self.managedObjectContextToMerge)
			{
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
				
				dispatch_semaphore_signal(mainContextSavedSemaphore);
			}
		}];
	});
	
	dispatch_semaphore_wait(mainContextSavedSemaphore, DISPATCH_TIME_FOREVER);
	
	/**
	 *  Finished is called on the same thread that the operation is on
	 *  once the semaphore has recived it's notification.
	 */
	[self finishOperation];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}

@end

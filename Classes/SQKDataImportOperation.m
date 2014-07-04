//
//  SQKJSONDataImportOperation.m
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKDataImportOperation.h"
#import "SQKContextManager.h"

@interface SQKDataImportOperation ()
@property (nonatomic, strong, readwrite) SQKContextManager *contextManager;
@property (nonatomic, strong, readwrite) id data;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContextToMerge;
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, assign) BOOL finished;
@end

@implementation SQKDataImportOperation

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager data:(id)data {
    self = [super init];
    if (self) {
        _contextManager = contextManager;
        _data = data;
        _executing = NO;
        _finished = NO;
    }
    return self;
}

#pragma mark - To overrride

- (NSError *)error {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)performWorkPrivateContext:(NSManagedObjectContext *)context usingData:(id)data {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}


#pragma mark - NSOperation

- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled]) {
        
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        self.finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    self.executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    self.managedObjectContextToMerge = [self.contextManager newPrivateContext];
    [self.managedObjectContextToMerge performBlockAndWait:^{
        [self performWorkPrivateContext:self.managedObjectContextToMerge usingData:self.data];
    }];
}

- (BOOL)isConcurrent {
    return NO;
}

- (BOOL)isExecuting {
    return self.executing;
}

- (BOOL)isFinished {
    return self.finished;
}


#pragma mark - Completion

- (void)completeOperationBySavingContext:(NSManagedObjectContext *)managedObjectContext {
    if ([self isCancelled]) {
        [self finishOperation];
    }
    else {
        self.managedObjectContextToMerge = managedObjectContext;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextSaveNotificationReceived:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
        
        [managedObjectContext save:NULL];
    }
}

- (void)finishOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    self.executing = NO;
    self.finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Merging

- (void)contextSaveNotificationReceived:(NSNotification *)notifcation {
    /**
     *  Ensure mainContext is accessed on the main thread.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        /**
         *  If NSManagedObjectContext from the notitification is a private context
         *	then merge the changes into the main context.
         */
        NSManagedObjectContext *managedObjectContext = [notifcation object];
        if (managedObjectContext == self.managedObjectContextToMerge) {
            NSManagedObjectContext *mainContext = [self.contextManager mainContext];
            
            /**
             *  This loop is needed for 'correct' behaviour of NSFetchedResultsControllers.
             *
             *  NSManagedObjectContext doesn't event fire NSManagedObjectContextObjectsDidChangeNotification for updated objects on merge, only inserted.
             *
             *  SEE: http://stackoverflow.com/questions/3923826/nsfetchedresultscontroller-with-predicate-ignores-changes-merged-from-different
             *  May also have memory implications.
             */
            for (NSManagedObject *object in [[notifcation userInfo] objectForKey:NSUpdatedObjectsKey]) {
                [[mainContext objectWithID:[object objectID]] willAccessValueForKey:nil];
            }
            
            [mainContext mergeChangesFromContextDidSaveNotification:notifcation];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
            [self finishOperation];
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}


@end

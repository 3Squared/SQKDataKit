//
//  SQKCoreDataOperation.h
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

@import Foundation;
@import CoreData;

@class SQKContextManager;

/**
 *  Use an SQKCoreDataOperation when you need to perform work with Core Data off the main thread.
 *  You need to subclass and must override the performWorkWithPrivateContext: method, which is where you
 *  should perform your work with Core Data. The operation will use its SQKContextManager to obtain a
 *  private managed object context. This is passed to the performWorkWithPrivateContext: method for you to
 *  use. When your work is complete call the completeOperationBySavingContext: method passing in the
 *  private context you have used. This saves the (private) managed object context, merges the changes
 *  into main context, and finishes the operation.
 *
 *  Add the operation to an NSOperationQueue that is not the mainQueue so that the computation is
 *  performed in a background thread. As a private context is used any insertions, updates, deletions
 *  etc must be done in a background thread, and using the correct operation queue will ensure that.
 */
@interface SQKCoreDataOperation : NSOperation

/**
 *  The context manager used for obtaining a private context.
 */
@property (nonatomic, readonly) SQKContextManager *contextManager;

/**
 *  Initialise a new `SQKCoreDataOperation` for performing work with Core Data in a background
 *  thread.
 *
 *  @param contextManager A context manager used to obtain a private managed object context for you
 *  to use in a background thread.
 *
 *  @return An initialised data import operation.
 */
- (instancetype)initWithContextManager:(SQKContextManager *)contextManager;

/**
 *  You must call this method when you want save the private context and your work is done.
 *  Saves the (private) managed object context, merges the changes into main context, and finishes
 *  operation.
 */
- (void)completeAndSave;

/**
 *  Deprecated. Use completeAndSave instead.
 */
- (void)completeOperationBySavingContext:(NSManagedObjectContext *)managedObjectContext DEPRECATED_MSG_ATTRIBUTE("Use completeAndSave instead");

/**
 *  Called from the `start` method when the operation is being executed. You must override this
 *  method and perform your Core Data specific logic here.
 *
 *  @param context A private managed object context for you to use.
 */
- (void)performWorkWithPrivateContext:(NSManagedObjectContext *)context;

/**
 *  Pass any errors encountered in your subclass so that they may be combined and returned by the error method.
 *
 *  @param error An error encountered while running your operation.
 */
- (void)addError:(NSError *)error;

/**
 *  Returns any error that occurred during the operation, including those added with addError:.
 */
- (NSError *)error;

@end

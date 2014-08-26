//
//  SQKManagedObjectController.h
//  SQKManagedObjectController
//
//  Created by Sam Oakley on 20/03/2014.
//  Copyright (c) 2014 Sam Oakley. All rights reserved.
//

@import Foundation;
@import CoreData;

@class SQKManagedObjectController;

extern NSString *const SQKManagedObjectControllerErrorDomain;

typedef void (^SQKManagedObjectControllerObjectsChangedBlock)(SQKManagedObjectController *controller,
                                                              NSIndexSet *changedObjectIndexes);
typedef void (^SQKManagedObjectControllerObjectsFetchedBlock)(SQKManagedObjectController *controller,
                                                              NSIndexSet *changedObjectIndexes,
                                                              NSError *error);


/**
 *  The delegate of a SQKManagedObjectController object must adopt the
 * SQKManagedObjectControllerDeledate protocol.
 *  Optional methods of the protocol allow the delegate to be informed of changes to the underlying
 * managed objects.
 */
@protocol SQKManagedObjectControllerDelegate <NSObject>
@optional

/**
 *  Called when objects are fetched as a result of a call to performFetch: or
 *performFetchAsynchronously.
 *  Always called on the main thread.
 *
 *  @param controller           The SQKManagedObjectController where the objects are fetched.
 *  @param fetchedObjectIndexes The indexes of the newly fetched objects. Will be all objects in the
 *array.
 *  @param error                If the fetch is not successful, this will be an error object that
 *describes the problem.
 */
- (void)controller:(SQKManagedObjectController *)controller
    fetchedObjects:(NSIndexSet *)fetchedObjectIndexes
             error:(NSError **)error;

/**
 *  Called when objects are updated after the main context is saved or changes are merged from a
 *background thread.
 *
 *  @param controller           The SQKManagedObjectController where the changes occured.
 *  @param savedObjectIndexes The indexes of the updated objects.
 */
- (void)controller:(SQKManagedObjectController *)controller
    didSaveObjects:(NSIndexSet *)savedObjectIndexes;

/**
 *  Called when objects are inserted that match the fetch request in the current managed object
 *context.
 *
 *  @param controller           The SQKManagedObjectController where the changes occured.
 *  @param insertedObjectIndexes The indexes of the inserted objects.
 */
- (void)controller:(SQKManagedObjectController *)controller
    didInsertObjects:(NSIndexSet *)insertedObjectIndexes;

/**
 *  Called when objects are deleted after the main context is saved or changes are merged from a
 *background thread.
 *
 *  @param controller           The SQKManagedObjectController where the deletions occured.
 *  @param deletedObjectIndexes The indexes of the deleted objects.
 */
- (void)controller:(SQKManagedObjectController *)controller
    didDeleteObjects:(NSIndexSet *)deletedObjectIndexes;
@end

/**
 *  This class helps manage NSManagedObjects in a similar way to NSFetchedResultsController.
 *  Should be used from the main thread unless otherwise noted.
 */
@interface SQKManagedObjectController : NSObject
@property (nonatomic, strong, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, strong, readonly) NSArray *managedObjects;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id<SQKManagedObjectControllerDelegate> delegate;

/**
 *  A block callback to be called when objects are fetched as a result of
 * performFetch:/performFetchAsync.
 */
@property (nonatomic, copy) SQKManagedObjectControllerObjectsFetchedBlock fetchedObjectsBlock;

/**
 *  A block callback to be called when objects are saved.
 */
@property (nonatomic, copy) SQKManagedObjectControllerObjectsChangedBlock savedObjectsBlock;

/**
 *  A block callback to be called when objects are deleted.
 */
@property (nonatomic, copy) SQKManagedObjectControllerObjectsChangedBlock deletedObjectsBlock;

/**
 *  A block callback to be called when objects are inserted that match the fetch request.
 */
@property (nonatomic, copy) SQKManagedObjectControllerObjectsChangedBlock insertedObjectsBlock;


/**
 *  Use the provided block to filter the array of fetched objects before adding them to
 * managedObjects.
 *  Useful if a predicate is not expressive enough for you.
 */
@property (nonatomic, copy) BOOL (^filterReturnedObjectsBlock)(id managedObject);


/**
 *  Returns a SQKManagedObjectController set up with the given fetch request and context.
 *  The fetch request is not executed until performFetch:/performFetchAsync is called.
 *
 *  @param fetchRequest A fetch request that specifies the search criteria for the fetch. Must not
 *be nil.
 *  @param context      The managed object context to use. Must be created with
 *NSMainQueueConcurrencyType, and must not be nil.
 *
 *  @return An initialised SQKManagedObjectController.
 */
- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest
                managedObjectContext:(NSManagedObjectContext *)context;

/**
 *  Returns a SQKManagedObjectController that manages the given array of NSManagedObjects.
 *  Used when you want to monitor changes on already-fetched objects.
 *  performFetch:/performFetchAsync are non-op for this controller.
 *
 *  @param managedObjects An array of NSManagedObjects created on a context with
 *NSMainQueueConcurrencyType. Must not be nil.
 *
 *  @return An initialised SQKManagedObjectController.
 */
- (instancetype)initWithManagedObjects:(NSArray *)managedObjects;

/**
 *  Returns a SQKManagedObjectController that manages the given NSManagedObject.
 *  Used when you want to monitor changes on an already-fetched object.
 *  performFetch:/performFetchAsync are non-op for this controller.
 *
 *  @param managedObjects A NSManagedObject created on a context with NSMainQueueConcurrencyType.
 *Must not be nil.
 *
 *  @return An initialised SQKManagedObjectController.
 */
- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject;

/**
 *  Execute the fetch request and store the results in self.managedObjects.
 *  Blocks the main thread. On returning, fetchedObjects will be available.
 *
 *  @param error If there is a problem executing the fetch, upon return contains an instance of
 *NSError that describes the problem.
 *
 *  @return YES if the fetch succeeds, otherwise NO.
 */
- (BOOL)performFetch:(NSError **)error;

/**
 *  Deleted the fetched objects from self.managedObjectContext and saves.
 *  self.managedObjects must contain objects.
 *  You must call [managedObjectContext save:] to commit these changes.
 *  Blocks the main thread. On returning, fetchedObjects will have been deleted.
 *
 *  @param error If there is a problem deleting, upon return contains an instance of NSError that
 *describes the problem.
 *
 *  @return YES if the delete succeeds, otherwise NO.
 */
- (BOOL)deleteObjects:(NSError **)error;


@end

//
//  SQKContextManager.h
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

@import Foundation;
@import CoreData;

/**
 *  SQKContextManager creates and manages NSManagedObjectContext instances on your behalf.
 *  It creates a persistent store coordinator behind the scenes.
 *  It provides a single `mainContext` to be used for UI based Core Data work (on the main thread).
 *  It creates private contexts (concurrency type `NSPrivateQueueConcurrencyType`) as you need them
 * for Core Data work on background threads.
 *  Saving a private context automatically merges any changes back in to the main managed object
 * context. (To disable automatic merging set the `shouldMergeOnSave` property of the private
 * context to NO.)
 *  You should construct and use a single SQKContextManager throughout your app. Pass the instance
 * to other objects that need to interact with Core Data.
 */
@interface SQKContextManager : NSObject

/**
 *  The persistent store coordinator used by the context manager.
 */
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  Initialises a context manager with a persistent store coordinator using the specifed store type and managed object model.
 *
 *  @param storeType A string specifying a supported store type by NSPersistentStoreCoordinator.
 *that specifies the store type.
 *  @param managedObjectModel A managed object model.
 *  @param storeURL Optional. Specify a custom location to create the persistent store, or nil. (Useful if you want to put the store in a shared location using App Groups for iOS 8+)

 *  @return A context manager, or nil if a) the store type is not unspported by NSPersistentStoreCoordinator, or b) the managed object model is nil.
 */
- (instancetype)initWithStoreType:(NSString *)storeType
               managedObjectModel:(NSManagedObjectModel *)managedObjectModel
                         storeURL:(NSURL *)storeURL;


/**
 *  Initialises a context manager with a persistent store coordinator.
 *
 *  @param persistentStoreCoordinator A configured persistent store coordinator.
 *
 *  @return A context manager.
 */
- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/**
 *  The main managed object context to be used for UI based Core Data work (on the main thread). A
 *`SQKContextManager` instance has a single main managed object context which is returned here. **Do
 *not use the main mamaged object context in a background thread.**
 *
 *  @return The main managed object context to be used for UI based Core Data work (on the main
 *thread).
 */
- (NSManagedObjectContext *)mainContext;

/**
 *  A new private context (concurrency type `NSPrivateQueueConcurrencyType`) for Core Data work on
 *background threads.
 *  A private context should be used whenever you are doing work off the main thread.
 *  If you want changes in this context to be automatically merged back into the main context on
 *save then set `shouldMergeOnSave` to YES.
 *  The context manager will perform the merge for you if set to YES. If you want to perform the
 *merge yourself and have more control over when
 *  and how the merge happens then set `shouldMergeOnSave` to NO.
 *
 *  @return A new private context (concurrency type `NSPrivateQueueConcurrencyType`) Core Data work
 *on background threads.
 */
- (NSManagedObjectContext *)newPrivateContext;

@end

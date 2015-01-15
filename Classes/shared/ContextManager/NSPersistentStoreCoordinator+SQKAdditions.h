//
//  NSPersistentStoreCoordinator+SQKExtensions.h
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

@import CoreData;

@interface NSPersistentStoreCoordinator (SQKAdditions)

/**
 *  Initialises a persistent store coordinator using the specifed store type and managed object model.
 *
 *  @param storeType          storeType A string specifying a supported store type by NSPersistentStoreCoordinator.
 *  @param managedObjectModel A managed object model.
 *  @param modelNames         The names of the MOM/MOMD/.xcdatamodel files in the app bundle, in order of creation. This allows automated migration between versions.
 *  @param storeURL           Optional. Specify a custom location to create the persistent store, or nil. Useful if you want to put the store in a shared location using App Groups.
 *
 *  @return A persistent store coordinator, or nil if a) the store type is not supported by NSPersistentStoreCoordinator, or b) the managed object model is nil.
 */
+ (instancetype)sqk_storeCoordinatorWithStoreType:(NSString *)storeType
                               managedObjectModel:(NSManagedObjectModel *)managedObjectModel
                   orderedManagedObjectModelNames:(NSArray *)modelNames
                                         storeURL:(NSURL *)storeURL;
@end
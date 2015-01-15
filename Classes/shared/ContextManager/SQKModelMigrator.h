//
//  SQKModelMigrator.h
//  Pods
//
//  Created by Sam Oakley on 05/11/2014.
//
//

@import CoreData;
@import Foundation;

extern NSString *const SQKDataKitMigrationErrorDomain;

@interface SQKModelMigrator : NSObject

/**
 *  Apply mapping models iteratively, eliminating the need to map between all model versions.
 *  e.g. 1 -> 2 -> 3
 *  instead of 1 -> 2, 2 -> 3, 1 -> 3
 *
 *  @param sourceStoreURL  The store URL that needs migration
 *  @param sourceStoreType A string specifying the type of the source store (SQL, InMemory, etc.)
 *  @param finalModel      The new managed object model.
 *  @param modelNames      The names of the MOM/MOMD/.xcdatamodel files in the app bundle, in order of creation. This allows automated migration between versions.
 *  @param error           An error pointer
 *
 *  @return A boolean indicating success or failure.
 */
+ (BOOL)iterativeMigrateURL:(NSURL *)sourceStoreURL
                            ofType:(NSString *)sourceStoreType
                           toModel:(NSManagedObjectModel *)finalModel
    orderedManagedObjectModelNames:(NSArray *)modelNames
                             error:(NSError **)error;

@end

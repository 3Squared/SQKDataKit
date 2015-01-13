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

+ (BOOL)iterativeMigrateURL:(NSURL *)sourceStoreURL
                            ofType:(NSString *)sourceStoreType
                           toModel:(NSManagedObjectModel *)finalModel
    orderedManagedObjectModelNames:(NSArray *)modelNames
                             error:(NSError **)error;

@end

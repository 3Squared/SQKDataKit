//
//  NSPersistentStoreCoordinator+SQKExtensions.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "NSPersistentStoreCoordinator+SQKAdditions.h"
#import "Bundle.h"

@implementation NSPersistentStoreCoordinator (SQKAdditions)

+ (instancetype)SQK_storeCoordinatorWithStoreType:(NSString *)storeType managedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    
    NSURL *storeURL = [self storeURL];
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @(YES),
                              NSInferMappingModelAutomaticallyOption : @(YES)
                              };
    NSError *error = nil;
    [persistentStoreCoordinator addPersistentStoreWithType:storeType
                                             configuration:nil
                                                       URL:storeURL
                                                   options:options
                                                     error:&error];
    if (error && isRunningFromProductionBundle()) {
        [self abortWithError:error];
    }
    return persistentStoreCoordinator;
}

+ (NSURL *)storeURL {
    NSDictionary *applicationInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *applicationName = [applicationInfo objectForKey:@"CFBundleDisplayName"];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", applicationName]];
}

+ (void)abortWithError:(NSError *)error {
    /*
     Replace this implementation with code to handle the error appropriately.
     
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     
     Typical reasons for an error here include:
     * The persistent store is not accessible;
     * The schema for the persistent store is incompatible with current managed object model.
     Check the error message to determine what the actual problem was.
     
     
     If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
     
     If you encounter schema incompatibility errors during development, you can reduce their frequency by:
     * Simply deleting the existing store:
     [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
     
     * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
     @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
     
     Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
     
     */
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
}

@end

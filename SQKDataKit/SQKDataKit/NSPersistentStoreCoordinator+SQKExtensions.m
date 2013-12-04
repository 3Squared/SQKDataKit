//
//  NSPersistentStoreCoordinator+SQKExtensions.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "NSPersistentStoreCoordinator+SQKExtensions.h"

@implementation NSPersistentStoreCoordinator (SQKExtensions)

+ (instancetype)SQK_storeCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    NSDictionary *applicationInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *applicationName = [applicationInfo objectForKey:@"CFBundleDisplayName"];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", applicationName]];
    
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:nil
                                                     error:&error];
    if (error) {
        return nil;
    }
    return persistentStoreCoordinator;
}

@end

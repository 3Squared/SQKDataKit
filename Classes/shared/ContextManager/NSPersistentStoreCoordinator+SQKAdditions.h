//
//  NSPersistentStoreCoordinator+SQKExtensions.h
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

@import CoreData;

@interface NSPersistentStoreCoordinator (SQKAdditions)

+ (instancetype)sqk_storeCoordinatorWithStoreType:(NSString *)storeType
                               managedObjectModel:(NSManagedObjectModel *)managedObjectModel
                   orderedManagedObjectModelNames:(NSArray *)modelNames
                                         storeURL:(NSURL *)storeURL;
@end

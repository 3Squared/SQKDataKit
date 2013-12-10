//
//  NSPersistentStoreCoordinator+SQKExtensions.h
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator (SQKAdditions)

+ (instancetype)SQK_storeCoordinatorWithStoreType:(NSString *)storeType managedObjectModel:(NSManagedObjectModel *)managedObjectModel;

@end

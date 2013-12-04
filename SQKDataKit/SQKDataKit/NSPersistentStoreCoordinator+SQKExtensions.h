//
//  NSPersistentStoreCoordinator+SQKExtensions.h
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator (SQKExtensions)

+ (instancetype)SQK_storeCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel storeType:(NSString *)storeType;

@end

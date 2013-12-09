//
//  NSManagedObject+SQKAdditions.h
//  SQKDataKit
//
//  Created by Luke Stringer on 05/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <CoreData/CoreData.h>

extern NSString * const SQKDataKitErrorDomain;

typedef NS_ENUM(NSInteger, SQKDataKitError) {
    SQKDataKitErrorUnsupportedQueueConcurencyType
};

@interface NSManagedObject (SQKAdditions)

+ (NSString *)SQK_entityName;

+ (NSEntityDescription *)SQK_entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (instancetype)SQK_insertInContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)SQK_fetchRequest;

+ (instancetype)SQK_findOrInsertByKey:(NSString *)key
                                value:(id)value
                              context:(NSManagedObjectContext *)context
                                error:(NSError **)error;

- (void)SQK_deleteObject;

+ (void)SQK_deleteAllObjectsInContext:(NSManagedObjectContext *)context error:(NSError **)error;

typedef void (^SQKPropertySetterBlock)(NSDictionary* dictionary, id managedObject);
+ (void)SQK_insertOrUpdate:(NSArray *)dictArray
            uniqueModelKey:(NSString *)modelKey
           uniqueRemoteKey:(NSString *)remoteDataKey
       propertySetterBlock:(SQKPropertySetterBlock)propertySetterBlock
                   privateContext:(NSManagedObjectContext *)context
                     error:(NSError **)error;


@end

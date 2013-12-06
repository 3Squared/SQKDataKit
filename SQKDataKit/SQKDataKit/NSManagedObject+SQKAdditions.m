//
//  NSManagedObject+SQKAdditions.m
//  SQKDataKit
//
//  Created by Luke Stringer on 05/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "NSManagedObject+SQKAdditions.h"

@implementation NSManagedObject (SQKAdditions)

+ (NSString *)SQK_entityName {
    return NSStringFromClass([self class]);
}

+ (NSEntityDescription *)SQK_entityDescriptionInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:[self SQK_entityName] inManagedObjectContext:context];
}

+ (instancetype)SQK_insertInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self SQK_entityName] inManagedObjectContext:context];
}

+ (NSFetchRequest *)SQK_fetchRequest {
    return [NSFetchRequest fetchRequestWithEntityName:[self SQK_entityName]];
}

+ (instancetype)SQK_findOrInsertByKey:(NSString *)key
                                value:(id)value
                              context:(NSManagedObjectContext *)context
                                error:(NSError **)error {
    NSFetchRequest *request = [self SQK_fetchRequest];
    [request setFetchLimit:1];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", key, value];
    [request setPredicate:predicate];
    
    NSError *localError = nil;
    NSArray *objects = [context executeFetchRequest:request error:&localError];
    
    // TODO return error
    
    id managedObject = [objects lastObject];
    if (!managedObject) {
        managedObject = [self SQK_insertInContext:context];
        [managedObject setValue:value forKey:key];
    }
    
    return managedObject;
}

- (void)SQK_deleteObject {
    [self.managedObjectContext deleteObject:self];
}

+ (void)SQK_deleteAllObjectsInContext:(NSManagedObjectContext *)context error:(NSError **)error {
    NSError *localError = nil;
    NSFetchRequest *fetchRequest = [self SQK_fetchRequest];
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&localError];
    if (localError) {
        *error = localError;
        return;
    }
    [objects makeObjectsPerformSelector:@selector(SQK_deleteObject)];
}

+ (void)SQK_insertOrUpdate:(NSArray *)dictArray
            uniqueModelKey:(NSString *)modelKey
           uniqueRemoteKey:(NSString *)remoteDataKey
       propertySetterBlock:(SQKPropertySetterBlock)propertySetterBlock
                   context:(NSManagedObjectContext *)context
                     error:(NSError **)error {
    for (NSDictionary *dict in dictArray) {
        NSError *findOrInsertError = nil;
        id managedObject = [self SQK_findOrInsertByKey:modelKey
                                                 value:dict[remoteDataKey]
                                               context:context
                                                 error:&findOrInsertError];
        propertySetterBlock(dict, managedObject);
    }
}

@end

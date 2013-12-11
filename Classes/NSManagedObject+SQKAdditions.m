//
//  NSManagedObject+SQKAdditions.m
//  SQKDataKit
//
//  Created by Luke Stringer on 05/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "NSManagedObject+SQKAdditions.h"

NSString * const SQKDataKitErrorDomain = @"SQKDataKitErrorDomain";

@implementation NSManagedObject (SQKAdditions)

+ (NSString *)SQK_entityName {
    
    if ([self class]== [NSManagedObject class]) {
        return nil;
    }
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

+ (instancetype)SQK_insertOrFetchWithKey:(NSString *)key
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
            privateContext:(NSManagedObjectContext *)context
                     error:(NSError **)error {
    
    if (!(context.concurrencyType == NSPrivateQueueConcurrencyType || context.concurrencyType ==  NSMainQueueConcurrencyType)) {
        *error = [self errorForUnsupportedQueueConcurencyType];
        return;
    }
    
    [context performBlockAndWait:^{
        NSSortDescriptor *remoteDataSortDescriptor = [[NSSortDescriptor alloc] initWithKey:remoteDataKey ascending:YES];
        NSArray *sortedDictArray = [dictArray sortedArrayUsingDescriptors:@[remoteDataSortDescriptor]];
        NSArray *fetchedRemoteIDs = [sortedDictArray valueForKeyPath:remoteDataKey];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[self SQK_entityDescriptionInContext:context]];
        [fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"(%K IN %@)", modelKey, fetchedRemoteIDs]];
        
        NSSortDescriptor *localDataSortDescriptor = [[NSSortDescriptor alloc] initWithKey:modelKey ascending:YES];
        [fetchRequest setSortDescriptors: @[localDataSortDescriptor]];
        
        NSError *localError = nil;
        NSArray *objectsMatchingKey = [context executeFetchRequest:fetchRequest error:&localError];
        if (localError) {
            return;
        }
        
        NSEnumerator *objectEnumerator = [objectsMatchingKey objectEnumerator];
        NSEnumerator *dictionaryEnumerator = [sortedDictArray objectEnumerator];
        
        NSDictionary* dictionary;
        id object = [objectEnumerator nextObject];
        
        while (dictionary = [dictionaryEnumerator nextObject]) {
            if (object && [[object valueForKey:modelKey] isEqualToString:dictionary[remoteDataKey]]) {
                if (propertySetterBlock) {
                    propertySetterBlock(dictionary, object);
                }
                object = [objectEnumerator nextObject];
            }
            else {
                id newObject = [[self class] SQK_insertInContext:context];
                [newObject setValue:dictionary[remoteDataKey] forKey:modelKey];
                if (propertySetterBlock) {
                    propertySetterBlock(dictionary, newObject);
                }
            }
        }
    }];
}

+ (NSPropertyDescription *)SQK_propertyDescriptionForName:(NSString*) name context:(NSManagedObjectContext *)context {
    return [[[[self class] SQK_entityDescriptionInContext:context] propertiesByName] objectForKey:name];
}

#pragma mark - Private

+ (NSError *)errorForUnsupportedQueueConcurencyType {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Insert or update operation failed due to unsupported concurrency type of the NSManagedObjectContext", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Use an NSManagedObjectContext with a concurency type of either NSPrivateQueueConcurrencyType or NSMainQueueConcurrencyType.", nil),
                               };
    
    return [NSError errorWithDomain:SQKDataKitErrorDomain
                               code:SQKDataKitErrorUnsupportedQueueConcurencyType
                           userInfo:userInfo];
}

@end

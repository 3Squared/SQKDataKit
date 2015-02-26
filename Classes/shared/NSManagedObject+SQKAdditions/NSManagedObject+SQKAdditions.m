//
//  NSManagedObject+SQKAdditions.m
//  SQKDataKit
//
//  Created by Luke Stringer on 05/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "NSManagedObject+SQKAdditions.h"
#import "SQKDataKitErrors.h"

@implementation NSManagedObject (SQKAdditions)

+ (NSString *)sqk_entityName
{
    if ([self class] == [NSManagedObject class])
    {
        return nil;
    }
    return [[NSStringFromClass([self class]) componentsSeparatedByString:@"."] lastObject];
}

+ (NSEntityDescription *)sqk_entityDescriptionInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:[self sqk_entityName] inManagedObjectContext:context];
}

+ (instancetype)sqk_insertInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self sqk_entityName]
                                         inManagedObjectContext:context];
}

+ (NSFetchRequest *)sqk_fetchRequest
{
    return [NSFetchRequest fetchRequestWithEntityName:[self sqk_entityName]];
}

+ (instancetype)sqk_insertOrFetchWithKey:(NSString *)key
                                   value:(id)value
                                 context:(NSManagedObjectContext *)context
                                   error:(NSError **)error
{
    NSFetchRequest *request = [self sqk_fetchRequest];
    [request setFetchLimit:1];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", key, value];
    [request setPredicate:predicate];

    NSError *localError = nil;
    NSArray *objects = [context executeFetchRequest:request error:&localError];
    if (localError)
    {
        // Check the passed error pointer is not nil
        if (error)
        {
            *error = localError;
        }
        return nil;
    }

    id managedObject = [objects lastObject];
    if (!managedObject)
    {
        managedObject = [self sqk_insertInContext:context];
        [managedObject setValue:value forKey:key];
    }

    return managedObject;
}

- (void)sqk_deleteObject
{
    [self.managedObjectContext deleteObject:self];
}

+ (void)sqk_deleteAllObjectsInContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    [context performBlockAndWait:^{
        NSError *localError = nil;
        NSFetchRequest *fetchRequest = [self sqk_fetchRequest];
        fetchRequest.includesPropertyValues = NO;
        fetchRequest.returnsObjectsAsFaults = NO;
        NSArray *objects = [context executeFetchRequest:fetchRequest error:&localError];
        if (localError)
        {
            if (error)
            {
                *error = localError;
            }
            return;
        }
        
        [objects makeObjectsPerformSelector:@selector(sqk_deleteObject)];
    }];
}

+ (void)sqk_deleteAllObjectsInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate error:(NSError **)error
{
    NSError *localError = nil;
    NSFetchRequest *fetchRequest = [self sqk_fetchRequest];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.predicate = predicate;
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&localError];
    if (localError)
    {
        if (error)
        {
            *error = localError;
        }
        return;
    }

    [objects makeObjectsPerformSelector:@selector(sqk_deleteObject)];
}

+ (void)sqk_insertOrUpdate:(NSArray *)remoteData
            uniqueModelKey:(id)modelKey
           uniqueRemoteKey:(id)remoteDataKey
       propertySetterBlock:(SQKPropertySetterBlock)propertySetterBlock
            privateContext:(NSManagedObjectContext *)context
                     error:(NSError **)error
{
    if (context.concurrencyType != NSPrivateQueueConcurrencyType)
    {
        if (error)
        {
            *error = [self errorForUnsupportedQueueConcurencyType];
        }
        return;
    }

    @autoreleasepool
    {
        // Remove any duplicates from remote data
        NSArray *fetchedRemoteIDs = [[NSSet setWithArray:[remoteData valueForKeyPath:remoteDataKey]] allObjects];

        // Sort the remote data IDs using their natural ordering
        NSSortDescriptor *remoteDataSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
        NSArray *sortedFetchedRemoteIDs = [fetchedRemoteIDs sortedArrayUsingDescriptors:@[ remoteDataSortDescriptor ]];

        // Reconstuct the remote data array of dictionaries - but ordered, and without duplicates
        NSMutableArray *sortedDictArray = [NSMutableArray array];
        for (id remoteId in sortedFetchedRemoteIDs)
        {
            for (id datum in remoteData)
            {
                if ([remoteId isEqual:[datum valueForKey:remoteDataKey]])
                {
                    [sortedDictArray addObject:datum];
                    break;
                }
            }
        }

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[self sqk_entityDescriptionInContext:context]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(%K IN %@)", modelKey, sortedFetchedRemoteIDs]];

        NSSortDescriptor *localDataSortDescriptor = [[NSSortDescriptor alloc] initWithKey:modelKey ascending:YES];
        [fetchRequest setSortDescriptors:@[ localDataSortDescriptor ]];

        NSError *localError = nil;
        NSArray *objectsMatchingKey = [context executeFetchRequest:fetchRequest error:&localError];
        if (localError)
        {
            *error = localError;
            return;
        }

        NSEnumerator *managedObjectEnumerator = [objectsMatchingKey objectEnumerator];
        NSEnumerator *remoteObjectEnumerator = [sortedDictArray objectEnumerator];

        id remoteObject;
        id managedObject = [managedObjectEnumerator nextObject];

        while (remoteObject = [remoteObjectEnumerator nextObject])
        {
            id remoteObjectKeyValue = [remoteObject valueForKey:remoteDataKey];
            if (remoteObjectKeyValue && remoteObjectKeyValue != [NSNull null])
            {
                if (managedObject && [[managedObject valueForKey:modelKey] isEqual:remoteObjectKeyValue])
                {
                    if (propertySetterBlock)
                    {
                        propertySetterBlock(remoteObject, managedObject);
                    }
                    managedObject = [managedObjectEnumerator nextObject];
                }
                else
                {
                    id newObject = [[self class] sqk_insertInContext:context];
                    [newObject setValue:remoteObjectKeyValue forKey:modelKey];
                    if (propertySetterBlock)
                    {
                        propertySetterBlock(remoteObject, newObject);
                    }
                }
            }
        }
    }
}

+ (NSPropertyDescription *)sqk_propertyDescriptionForName:(NSString *)name
                                                  context:(NSManagedObjectContext *)context
{
    return [[[[self class] sqk_entityDescriptionInContext:context] propertiesByName] objectForKey:name];
}

#pragma mark - Private

+ (NSError *)errorForUnsupportedQueueConcurencyType
{
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : NSLocalizedString(@"Insert or update operation failed due to unsupported concurrency "
                                                      @"type of the NSManagedObjectContext",
                                                      nil),
        NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Use an NSManagedObjectContext with a concurency type of either "
                                                             @"NSPrivateQueueConcurrencyType or NSMainQueueConcurrencyType.",
                                                             nil),
    };

    return [NSError errorWithDomain:SQKDataKitErrorDomain
                               code:SQKDataKitErrorUnsupportedQueueConcurencyType
                           userInfo:userInfo];
}

@end

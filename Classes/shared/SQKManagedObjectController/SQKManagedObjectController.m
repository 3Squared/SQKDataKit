//
//  SQKManagedObjectController.m
//  SQKManagedObjectController
//
//  Created by Sam Oakley on 20/03/2014.
//  Copyright (c) 2014 Sam Oakley. All rights reserved.
//

#import "SQKManagedObjectController.h"
#import "NSArray+SQKAdditions.h"

NSString *const SQKManagedObjectControllerErrorDomain = @"SQKManagedObjectControllerErrorDomain";

@interface SQKManagedObjectController ()
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSArray *managedObjects;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation SQKManagedObjectController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];

        self.filterReturnedObjectsBlock = ^BOOL(NSManagedObject *obj) { return YES; };
    }
    return self;
}

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest
                managedObjectContext:(NSManagedObjectContext *)context
{
    if (!fetchRequest || !context)
    {
        return nil;
    }
    self = [self init];
    if (self)
    {
        _fetchRequest = fetchRequest;
        _managedObjectContext = context;
    }
    return self;
}

- (instancetype)initWithManagedObjects:(NSArray *)managedObjects
{
    if (!managedObjects || managedObjects.count == 0)
    {
        return nil;
    }

    self = [self init];
    if (self)
    {
        _managedObjectContext = [[managedObjects firstObject] managedObjectContext];
        _managedObjects = [managedObjects copy];
    }
    return self;
}

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject
{
    if (!managedObject)
    {
        return nil;
    }

    return [self initWithManagedObjects:@[ managedObject ]];
}

- (void)dealloc
{
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}

#pragma mark Fetching

- (BOOL)performFetch:(NSError **)error
{
    return [self performFetch:error notify:YES];
}

- (BOOL)performFetch:(NSError **)error notify:(BOOL)shouldNotify
{
    if (!self.fetchRequest)
    {
        *error = [NSError errorWithDomain:SQKManagedObjectControllerErrorDomain
                                     code:1
                                 userInfo:@{
                                     NSLocalizedDescriptionKey : @"No fetch request set!"
                                 }];
        return NO;
    }

    NSArray *fetchedObjects =
        [self.managedObjectContext executeFetchRequest:self.fetchRequest error:error];

    NSIndexSet *indexes = [fetchedObjects indexesOfObjectsPassingTest:^BOOL(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
            return self.filterReturnedObjectsBlock(obj);
    }];
    self.managedObjects = [fetchedObjects objectsAtIndexes:indexes];

    if (shouldNotify)
    {
        NSIndexSet *allIndexes = [self.managedObjects sqk_indexesOfObjects];
        if ([self.delegate respondsToSelector:@selector(controller:fetchedObjects:error:)])
        {
            [self.delegate controller:self fetchedObjects:allIndexes error:error];
        }
        if (self.fetchedObjectsBlock)
        {
            self.fetchedObjectsBlock(self, allIndexes, *error);
        }
    }

    return error ? NO : YES;
}

#pragma mark - Operations

- (BOOL)deleteObjects:(NSError **)error
{
    if (!self.managedObjects && error)
    {
        *error = [NSError errorWithDomain:SQKManagedObjectControllerErrorDomain
                                     code:2
                                 userInfo:@{
                                     NSLocalizedDescriptionKey : @"No objects to delete! You must call performFetch: first."
                                 }];
        return NO;
    }

    for (NSManagedObject *object in self.managedObjects)
    {
        [self.managedObjectContext deleteObject:object];
    }

    return error ? NO : YES;
}

#pragma mark - Private context

- (NSManagedObjectContext *)newPrivateContext
{
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateContext.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    return privateContext;
}

#pragma mark - Lazy initialisers

- (NSOperationQueue *)queue
{
    if (_queue)
    {
        return _queue;
    }
    _queue = [[NSOperationQueue alloc] init];
    return _queue;
}

#pragma mark - NSNotifications

- (void)contextDidSave:(NSNotification *)notification
{
    if (self.fetchRequest)
    {
        NSArray *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];

        if (insertedObjects.count > 0)
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.managedObjects];
            for (NSManagedObject *insertedObject in insertedObjects)
            {
                BOOL isCorrectEntityType = [insertedObject.entity.name isEqualToString:self.fetchRequest.entityName];
                if (isCorrectEntityType)
                {
                    BOOL matchesPredicate = !self.fetchRequest.predicate || [self.fetchRequest.predicate evaluateWithObject:insertedObject];
                    if (matchesPredicate)
                    {
                        __block NSManagedObject *localObject = nil;
                        [self.managedObjectContext performBlockAndWait:^{
                            localObject = [self.managedObjectContext existingObjectWithID:[insertedObject objectID] error:nil];
                        }];

                        if (localObject && self.filterReturnedObjectsBlock(localObject))
                        {
                            [array addObject:localObject];
                        }
                    }
                }
            }

            if (self.fetchRequest.sortDescriptors)
            {
                [self.managedObjectContext performBlockAndWait:^{
                    [array sortUsingDescriptors:self.fetchRequest.sortDescriptors];
                }];
            }

            self.managedObjects = [NSArray arrayWithArray:array];

            NSIndexSet *insertedIndexes =
                [self.managedObjects indexesOfObjectsPassingTest:^BOOL(NSManagedObject *existingObject, NSUInteger idx, BOOL *stop) {
                    for (NSManagedObject *insertedObject in insertedObjects)
                    {
                        if ([insertedObject.objectID isEqual:existingObject.objectID])
                        {
                            return YES;
                        }
                    }
                    return NO;
                }];

            if (insertedIndexes.count > 0)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if ([self.delegate respondsToSelector:@selector(controller:didInsertObjects:)])
                    {
                        [self.delegate controller:self didInsertObjects:insertedIndexes];
                    }
                    if (self.insertedObjectsBlock)
                    {
                        self.insertedObjectsBlock(self, insertedIndexes);
                    }
                }];
            }
        }
    }

    if (!self.managedObjects || self.managedObjects.count == 0)
    {
        return;
    }

    NSArray *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    NSArray *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];

    if (([self.delegate respondsToSelector:@selector(controller:didSaveObjects:)] || self.savedObjectsBlock) && updatedObjects && updatedObjects.count > 0)
    {
        NSIndexSet *updatedIndexes =
            [self.managedObjects indexesOfObjectsPassingTest:^BOOL(NSManagedObject *existingObject, NSUInteger idx, BOOL *stop) {
                for (NSManagedObject *updatedObject in updatedObjects)
                {
                    if ([updatedObject.objectID isEqual:existingObject.objectID])
                    {
                        [self.managedObjectContext performBlockAndWait:^{
                            [self.managedObjectContext refreshObject:existingObject mergeChanges:NO];
                        }];
                        return YES;
                    }
                }
                return NO;
            }];

        if (updatedIndexes.count > 0)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if ([self.delegate respondsToSelector:@selector(controller:didSaveObjects:)])
                {
                    [self.delegate controller:self didSaveObjects:updatedIndexes];
                }
                if (self.savedObjectsBlock)
                {
                    self.savedObjectsBlock(self, updatedIndexes);
                }
            }];
        }
    }

    if (([self.delegate respondsToSelector:@selector(controller:didDeleteObjects:)] || self.deletedObjectsBlock) && deletedObjects && deletedObjects.count > 0)
    {
        NSIndexSet *deletedIndexes =
            [self.managedObjects indexesOfObjectsPassingTest:^BOOL(NSManagedObject *existingObject, NSUInteger idx, BOOL *stop) {
                for (NSManagedObject *deletedObject in deletedObjects)
                {
                    if ([deletedObject.objectID isEqual:existingObject.objectID])
                    {
                        [self.managedObjectContext performBlockAndWait:^{
                            [self.managedObjectContext refreshObject:existingObject mergeChanges:NO];
                        }];
                        return YES;
                    }
                }
                return NO;
            }];

        if (deletedIndexes.count > 0)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if ([self.delegate respondsToSelector:@selector(controller:didDeleteObjects:)])
                {
                    [self.delegate controller:self didDeleteObjects:deletedIndexes];
                }
                if (self.deletedObjectsBlock)
                {
                    self.deletedObjectsBlock(self, deletedIndexes);
                }
            }];
        }
    }
}

@end

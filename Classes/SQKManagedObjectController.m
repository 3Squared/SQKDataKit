//
//  SQKManagedObjectController.m
//  SQKManagedObjectController
//
//  Created by Sam Oakley on 20/03/2014.
//  Copyright (c) 2014 Sam Oakley. All rights reserved.
//

#import "SQKManagedObjectController.h"
#import "NSArray+SQKAdditions.h"

NSString* const SQKManagedObjectControllerErrorDomain = @"SQKManagedObjectControllerErrorDomain";

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
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context
{
    if (!fetchRequest || !context) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        _fetchRequest = fetchRequest;
        _managedObjectContext = context;
    }
    return self;
}

- (instancetype)initWithWithManagedObjects:(NSArray *)managedObjects
{
    if (!managedObjects || managedObjects.count == 0) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        _managedObjectContext = [[managedObjects firstObject] managedObjectContext];
        _managedObjects = [managedObjects copy];
    }
    return self;
}

- (instancetype)initWithWithManagedObject:(NSManagedObject *)managedObject
{
    if (!managedObject) {
        return nil;
    }
    
    return [self initWithWithManagedObjects:@[managedObject]];
}

-(void)dealloc
{
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}

#pragma mark Fetching

- (BOOL)performFetch:(NSError**)error
{
    if (!self.fetchRequest) {
        *error = [NSError errorWithDomain:SQKManagedObjectControllerErrorDomain
                                     code:1
                                 userInfo:@{NSLocalizedDescriptionKey : @"No fetch request set!"}];
        return NO;
    }
    
    self.managedObjects = [self.managedObjectContext executeFetchRequest:self.fetchRequest error:error];
    NSIndexSet *allIndexes = [self.managedObjects sqk_indexesOfObjects];
    if ([self.delegate respondsToSelector:@selector(controller:fetchedObjects:error:)]) {
        [self.delegate controller:self fetchedObjects:allIndexes error:error];
    }
    if (self.fetchedObjectsBlock) {
        self.fetchedObjectsBlock(allIndexes, *error);
    }
    return error ? NO : YES;
}

- (void)performFetchAsynchronously
{
    if (!self.fetchRequest) {
        return;
    }
    
    [self.queue addOperationWithBlock:^{
        NSManagedObjectContext* privateContext = [self newPrivateContext];
        
        __block NSArray *fetchedObjects;
        __block NSError *error = nil;
        [privateContext performBlockAndWait:^{
            fetchedObjects = [privateContext executeFetchRequest:self.fetchRequest error:&error];
        }];
        
        NSArray *managedObjectIds = [fetchedObjects valueForKey:@"objectID"];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSMutableArray *objectsToReturn = [NSMutableArray array];
            for (NSManagedObjectID *objectID in managedObjectIds) {
                [objectsToReturn addObject:[self.managedObjectContext objectWithID:objectID]];
            }
            self.managedObjects = [NSArray arrayWithArray:objectsToReturn];
            if ([self.delegate respondsToSelector:@selector(controller:fetchedObjects:error:)]) {
                [self.delegate controller:self fetchedObjects:[self.managedObjects sqk_indexesOfObjects] error:&error];
            }
        }];
        
    }];
}

#pragma mark - Operations

- (BOOL)deleteObjects:(NSError**)error
{
    if (!self.managedObjects) {
        *error = [NSError errorWithDomain:SQKManagedObjectControllerErrorDomain
                                     code:2
                                 userInfo:@{NSLocalizedDescriptionKey : @"No objects to delete! You must call performFetch: first."}];
        return NO;
    }
    
    for (NSManagedObject *object in self.managedObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    return error ? NO : YES;
}

-(void)deleteObjectsAsynchronously
{
    NSArray *objectIDs = [self.managedObjects valueForKey:@"objectID"];
    [self.queue addOperationWithBlock:^{
        NSManagedObjectContext *privateContext = [self newPrivateContext];
        [privateContext performBlockAndWait:^{
            for (NSManagedObjectID *objectID in objectIDs) {
                [privateContext deleteObject:[privateContext objectWithID:objectID]];
            }
            [privateContext save:nil];
        }];
    }];
}

#pragma mark - Private context

-(NSManagedObjectContext*) newPrivateContext
{
    NSManagedObjectContext* privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateContext.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    return privateContext;
}

#pragma mark - Lazy initialisers

-(NSOperationQueue *)queue
{
    if (_queue) {
        return _queue;
    }
    _queue = [[NSOperationQueue alloc] init];
    return _queue;
}

#pragma mark - NSNotifications

- (void)contextDidSave:(NSNotification*)notification
{
    if (!self.managedObjects && self.delegate) {
        return;
    }
    
    NSArray *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    NSArray *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    
    if (([self.delegate respondsToSelector:@selector(controller:updatedObjects:)] || self.updatedObjectsBlock) && updatedObjects && updatedObjects.count > 0) {
        NSIndexSet *updatedIndexes = [self.managedObjects indexesOfObjectsPassingTest:^BOOL(NSManagedObject* existingObject, NSUInteger idx, BOOL *stop) {
            for (NSManagedObject *updatedObject in updatedObjects) {
                if ([updatedObject.objectID isEqual:existingObject.objectID]) {
                    [self.managedObjectContext refreshObject:existingObject mergeChanges:NO];
                    return YES;
                }
            }
            return NO;
        }];
        
        if (updatedIndexes.count > 0) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if ([self.delegate respondsToSelector:@selector(controller:updatedObjects:)]) {
                    [self.delegate controller:self updatedObjects:updatedIndexes];
                }
                if (self.updatedObjectsBlock) {
                    self.updatedObjectsBlock(updatedIndexes);
                }
            }];
        }
    }
    
    if (([self.delegate respondsToSelector:@selector(controller:deletedObjects:)] || self.deletedObjectsBlock) && deletedObjects && deletedObjects.count > 0) {
        NSIndexSet *deletedIndexes = [self.managedObjects indexesOfObjectsPassingTest:^BOOL(NSManagedObject* existingObject, NSUInteger idx, BOOL *stop) {
            for (NSManagedObject *deletedObject in deletedObjects) {
                if ([deletedObject.objectID isEqual:existingObject.objectID]) {
                    [self.managedObjectContext refreshObject:existingObject mergeChanges:NO];
                    return YES;
                }
            }
            return NO;
        }];
        
        if (deletedIndexes.count > 0) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if ([self.delegate respondsToSelector:@selector(controller:deletedObjects:)]) {
                    [self.delegate controller:self deletedObjects:deletedIndexes];
                }
                if (self.deletedObjectsBlock) {
                    self.deletedObjectsBlock(deletedIndexes);
                }
            }];
        }
    }
}


@end

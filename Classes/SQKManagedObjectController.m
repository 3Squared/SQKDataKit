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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext* privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        privateContext.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
        
        __block NSArray *fetchedObjects;
        __block NSError *error = nil;
        [privateContext performBlockAndWait:^{
            fetchedObjects = [privateContext executeFetchRequest:self.fetchRequest error:&error];
        }];
        
        NSArray *managedObjectIds = [fetchedObjects valueForKey:@"objectID"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *objectsToReturn = [NSMutableArray array];
            for (NSManagedObjectID *objectID in managedObjectIds) {
                [objectsToReturn addObject:[self.managedObjectContext objectWithID:objectID]];
            }
            self.managedObjects = [NSArray arrayWithArray:objectsToReturn];
            if ([self.delegate respondsToSelector:@selector(controller:fetchedObjects:error:)]) {
                [self.delegate controller:self fetchedObjects:[self.managedObjects sqk_indexesOfObjects] error:&error];
            }
        });
        
    });
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
    [self.managedObjectContext save:error];
    
    return error ? NO : YES;
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
                    return YES;
                }
            }
            return NO;
        }];
        
        if (updatedIndexes.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(controller:updatedObjects:)]) {
                    [self.delegate controller:self updatedObjects:updatedIndexes];
                }
                if (self.updatedObjectsBlock) {
                    self.updatedObjectsBlock(updatedIndexes);
                }
            });
        }
    }
    
    if (([self.delegate respondsToSelector:@selector(controller:deletedObjects:)] || self.deletedObjectsBlock) && deletedObjects && deletedObjects.count > 0) {
        NSIndexSet *deletedIndexes = [self.managedObjects indexesOfObjectsPassingTest:^BOOL(NSManagedObject* existingObject, NSUInteger idx, BOOL *stop) {
            for (NSManagedObject *deletedObject in deletedObjects) {
                if ([deletedObject.objectID isEqual:existingObject.objectID]) {
                    return YES;
                }
            }
            return NO;
        }];
        
        if (deletedIndexes.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(controller:deletedObjects:)]) {
                    [self.delegate controller:self deletedObjects:deletedIndexes];
                }
                if (self.deletedObjectsBlock) {
                    self.deletedObjectsBlock(deletedIndexes);
                }
            });
        }
    }
}

@end

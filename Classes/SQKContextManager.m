//
//  SQKContextManager.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKContextManager.h"
#import "NSPersistentStoreCoordinator+SQKAdditions.h"

@interface SQKContextManager ()
@property (nonatomic, strong, readwrite) NSString *storeType;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSManagedObjectContext* mainContext;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@end

@implementation SQKContextManager

- (instancetype)initWithStoreType:(NSString *)storeType managedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    if (!storeType || !managedObjectModel) {
        return nil;
    }
    
    NSArray *validStoreTypes = @[NSSQLiteStoreType, NSInMemoryStoreType, NSBinaryStoreType];
    if (![validStoreTypes containsObject:storeType]) {
        return nil;
    }
    
    
    self = [super init];
    if (self) {
        self.storeType = storeType;
        self.managedObjectModel = managedObjectModel;
        self.persistentStoreCoordinator = [NSPersistentStoreCoordinator SQK_storeCoordinatorWithStoreType:storeType managedObjectModel:managedObjectModel];
        [self observeForSavedNotification];
    }
    return self;
}

- (void)observeForSavedNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification* note) {
                                                      NSManagedObjectContext *managedObjectContext = [note object];
                                                      for(NSManagedObject *object in [[note userInfo] objectForKey:NSUpdatedObjectsKey]) {
                                                          [[managedObjectContext objectWithID:[object objectID]] willAccessValueForKey:nil];
                                                      }
                                                      [self.mainContext mergeChangesFromContextDidSaveNotification:note];
                                                  }];
}

- (NSManagedObjectContext *)mainContext {
    if (_mainContext != nil) {
        return _mainContext;
    }
    
    _mainContext = [[NSManagedObjectContext alloc] init];
    _mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return _mainContext;
}

- (NSManagedObjectContext*)newPrivateContext {
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return context;
}

- (BOOL)saveMainContext:(NSError **)error {
    if ([self.mainContext hasChanges]) {
        // TODO: Perform on main thread?
        [self.mainContext save:error];
        return YES;
    }
    return NO;
}

@end

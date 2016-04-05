//
//  SQKContextManager.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKContextManager.h"
#import "NSPersistentStoreCoordinator+SQKAdditions.h"
#import "NSManagedObjectContext+SQKAdditions.h"

@interface SQKContextManager ()

@property (nonatomic, strong, readwrite) NSString *storeType;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSArray *modelNames;
@property (nonatomic, strong, readwrite) NSURL *storeURL;

@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;

@end

@implementation SQKContextManager

- (instancetype)initWithStoreType:(NSString *)storeType
               managedObjectModel:(NSManagedObjectModel *)managedObjectModel
   orderedManagedObjectModelNames:(NSArray *)modelNames
                         storeURL:(NSURL *)storeURL
{
    if (!storeType || !managedObjectModel || ![[SQKContextManager validStoreTypes] containsObject:storeType])
    {
        return nil;
    }
    
    self = [super init];
    
    if(self)
    {
        _persistentStoreCoordinator = [NSPersistentStoreCoordinator sqk_storeCoordinatorWithStoreType:storeType
                                                                                   managedObjectModel:managedObjectModel
                                                                       orderedManagedObjectModelNames:modelNames
                                                                                             storeURL:storeURL];
        
        self.storeType = storeType;
        self.managedObjectModel = managedObjectModel;
        self.modelNames = modelNames;
        self.storeURL = storeURL;
        
        [self observeForSavedNotification];
    }
    
    return self;
    
}

+ (NSArray *)validStoreTypes
{
    NSArray *validStoreTypes = nil;
    if (!validStoreTypes)
    {
        validStoreTypes = @[ NSSQLiteStoreType, NSInMemoryStoreType, NSBinaryStoreType ];
    }
    return validStoreTypes;
}

- (void)observeForSavedNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextSaveNotificationReceived:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
}

- (void)contextSaveNotificationReceived:(NSNotification *)notification
{
    /**
     *  Ensure mainContext is accessed on the main thread.
     */
    [_mainContext performBlock:^{
        NSManagedObjectContext *managedObjectContext = [notification object];
        if ([managedObjectContext shouldMergeOnSave] && managedObjectContext.concurrencyType == NSPrivateQueueConcurrencyType)
        {
            /*  If NSManagedObjectContext from the notitification is a private context
            *	then merge the changes into the main context.
            */
            [_mainContext mergeChangesFromContextDidSaveNotification:notification];

            /**
             * This loop is needed for 'correct' behaviour of NSFetchedResultsControllers.
             *
             * NSManagedObjectContext doesn't event fire
             * NSManagedObjectContextObjectsDidChangeNotification for updated objects on merge,
             * only inserted.
             *
             * SEE:
             * http://stackoverflow.com/questions/3923826/nsfetchedresultscontroller-with-predicate-ignores-changes-merged-from-different
             *  May also have memory implications.
             */
            for (NSManagedObject *object in [[notification userInfo] objectForKey:NSUpdatedObjectsKey])
            {
                [[_mainContext objectWithID:[object objectID]] willAccessValueForKey:nil];
            }
        }
    }];
}

- (NSManagedObjectContext *)mainContext
{
    if (![NSThread isMainThread])
    {
        @throw [NSException exceptionWithName:NSObjectInaccessibleException
                                       reason:@"mainContext is only accessible from the main thread!"
                                     userInfo:nil];
    }

    if (_mainContext != nil)
    {
        return _mainContext;
    }

    _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return _mainContext;
}

- (NSManagedObjectContext *)newPrivateContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return context;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}

@end

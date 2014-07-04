//
//  SQKJSONDataImportOperation.h
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQKContextManager;

/**
 *  Use an SQKDataImportOperation when you need to import data into Core Data off the main thread. You need to subclass and must override the `updateContext:usingData:` method, which is where you should perform your data import logic. The operation will use it's `SQKContextManager` to obtain a private managed object context. This is passed to the `updateContext:usingData:` method for you to use during import. Add the operation to an NSOperationQueue that is not the `mainQueue` so that the computation is performed off the main thread. As a private context is used any insertions, updates, deletions etc must be done in a background thread, and using the correct operation queue will ensure that.
 *  @discussion Subclass example:
 *      ```
        #import "CustomDataImportOperation.h"
        #import "Animal.h"
        #import "NSManagedObject+SQKAdditions.h"

        @interface CustomDataImportOperation ()
        @end

        @implementation CustomDataImportOperation

        - (void)updateContext:(NSManagedObjectContext *)context usingData:(id)data {
            [Animal sqk_insertOrUpdate:data
                        uniqueModelKey:@"animalID"
                       uniqueRemoteKey:@"IDAnimal"
                   propertySetterBlock:^(NSDictionary *dictionary, id managedObject) {
                       Animal *animal = (Animal *)managedObject;
                       animal.name = dictionary[@"Name"];
                       animal.age = dictionary[@"Age"];
                   }
                        privateContext:self.privateContext
                                 error:&error];
            [context save:nil];
        }
        @end
        ```
 *      Using:
 *      ```
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init]; // background thread queue
        id JSON = ...; // data to import (NSArray or NSDictionary typically)
        
        CustomDataImportOperation *importOperation = [[CustomDataImportOperation alloc] initWithContextManager:self.contextManager data:JSON];
        [importOperation setCompletionBlock:^{
            // Completion logic here
        }];
        
        [self.operationQueue addOperation:importOperation];
 *      ```
 *  Inspired by the obj-c.io article on threading and concurrency. http://www.objc.io/issue-2/concurrency-apis-and-pitfalls.html
 */
@interface SQKDataImportOperation : NSOperation

/**
 *  The context manager used for obtaining a private context.
 */
@property (nonatomic, readonly) SQKContextManager *contextManager;

/**
 *  The data to import. Passed to the `updateContext:usingData:` method.
 */
@property (nonatomic, readonly) id data;

/**
 *  Initialise a new `SQKDataImportOperation` for importing data into Core Data off the main thread.
 *
 *  @param contextManager A context manager used to obtain a private managed object context to import data in a background thread.
 *  @param data           The data to import. This is passed to the `updateContext:usingData:` when the operation is executed.
 *
 *  @return An initialised data import operation.
 */
- (instancetype)initWithContextManager:(SQKContextManager *)contextManager data:(id)data;

/**
 *  MUST call this method when data import has finished. Saves the managed object context, merges changes into main context and finishes operation.
 *
 *  @param managedObjectContext The managed object context save to and merge.
 */
- (void)completeOperationBySavingContext:(NSManagedObjectContext *)managedObjectContext;

/**
 *  Called from the `main` method when the operation is executed. You must override this method and provide an implementation that performs the necessary import logic.
 *
 *  @param context A private managed object context to use for data import.
 *  @param data    The data to import, as specified in the constructor.
 */
- (void)performWorkPrivateContext:(NSManagedObjectContext *)context usingData:(id)data;

/**
 *  Override to return any error that occurred during the import operation.
 */
- (NSError *)error;

@end

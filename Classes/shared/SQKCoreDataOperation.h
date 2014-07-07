//
//  SQKCoreDataOperation.h
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQKContextManager;

/**
 *  Use an SQKCoreDataOperation when you need to perform work with Core Data off the main thread. You need to subclass and must override the `performWorkPrivateContext:` method, which is where you should perform your work with Core Data. The operation will use it's `SQKContextManager` to obtain a private managed object context. This is passed to the `performWorkPrivateContext:` method for you to use. When your work is complete call the `completeOperationBySavingContext:` method passing in the private context you have used. This saves the (private) managed object context, merges the changes into main context, and finishes operation.
*   Add the operation to an NSOperationQueue that is not the `mainQueue` so that the computation is performed in a background thread. As a private context is used any insertions, updates, deletions etc must be done in a background thread, and using the correct operation queue will ensure that.
 *  Inspired by the obj-c.io article on threading and concurrency. http://www.objc.io/issue-2/concurrency-apis-and-pitfalls.html
 *  @discussion Subclass example:
 *
```
#import "AnimalImportOperation.h"
#import "Animal.h"
#import "NSManagedObject+SQKAdditions.h"

@interface AnimalImportOperation ()
@end

@implementation AnimalImportOperation

- (void)performWorkPrivateContext:(NSManagedObjectContext *)context {
    id animalJSON = [self animalJSONFromWebservice];
    
    [Animal SQK_insertOrUpdate:animalJSON
                uniqueModelKey:@"animalID"
               uniqueRemoteKey:@"IDAnimal"
           propertySetterBlock:^(NSDictionary *dictionary, id managedObject) {
               Animal *animal = (Animal *)managedObject;
               animal.name = dictionary[@"Name"];
               animal.age = dictionary[@"Age"];
           }
                privateContext:self.privateContext
                         error:NULL];
    [context save:NULL];
}

- (id)animalJSONFromWebservice {
    NSURL *URL = [NSURL URLWithString:@"http://webservice.com/v1/animal"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *reponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
    id JSON = reponseData != nil ? [NSJSONSerialization JSONObjectWithData:reponseData options:0 error:NULL] : nil;
    
    return JSON
}

@end
```
 *  Using with an operation queue.
```
NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init]; // background thread queue

AnimalImportOperation *importOperation = [[AnimalImportOperation alloc] initWithContextManager:self.contextManager];

[importOperation setCompletionBlock:^{
    // Completion logic here
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // You may want to perform this on the main thread
	}];
}];

[self.operationQueue addOperation:importOperation];
```
 */
@interface SQKCoreDataOperation : NSOperation

/**
 *  The context manager used for obtaining a private context.
 */
@property (nonatomic, readonly) SQKContextManager *contextManager;


/**
 *  Initialise a new `SQKCoreDataOperation` for performing work with Core Data in a background thread.
 *
 *  @param contextManager A context manager used to obtain a private managed object context for you to use in a background thread.
 *
 *  @return An initialised data import operation.
 */
- (instancetype)initWithContextManager:(SQKContextManager *)contextManager;

/**
 *  You must call this method when you want save the private context and your work is done.
 *  Saves the (private) managed object context, merges the changes into main context, and finishes operation.
 *
 *  @param managedObjectContext The managed object context save to and merge.
 */
- (void)completeOperationBySavingContext:(NSManagedObjectContext *)managedObjectContext;

/**
 *  Called from the `start` method when the operation is being executed. You must override this method and perform your Core Data specific logic here.
 *
 *  @param context A private managed object context for you to use.
 */
- (void)performWorkPrivateContext:(NSManagedObjectContext *)context;

/**
 *  Override to return any error that occurred during the operation.
 */
- (NSError *)error;

@end

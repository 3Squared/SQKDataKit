# SQKDataKit ![Version](https://cocoapod-badges.herokuapp.com/v/SQKDataKit/badge.png)&nbsp;![Platforms](https://cocoapod-badges.herokuapp.com/p/SQKDataKit/badge.png)

Collection of classes to make working with Core Data easier and help DRY-up your code. Provides convenience methods and classes for working in a multi-threaded environment with `NSManagedObject`s and `NSManagedObjectContext`s. Codifies some good practises for importing large data sets efficiently.

# Installation

* Using [Cocoapods](http://cocoapods.org), add `pod SQKDataKit` to your Podfile.
* `#import <SQKDataKit/SQKDataKit.h>` as necessary.


# Usage

## `SQKContextManager`

`SQKContextManager` is you first point of entry for using SQKDataKit. It creates and manages `NSManagedObjectContext` instances for you. 

### Initialisation

You should only ever use a single `SQKContextManager` as it maintains the persistent store coordinator instance for your Core Data stack. It is recommended you create it during the initial load of the app, for example in your AppDelegate. Initialise a context manager with a concurrency type and a managed object model:

```
#import <SQKDataKit/SQKDataKit.h>`

@interface SQKAppDelegate ()
@property (nonatomic, readwrite, strong) SQKContextManager *contextManager;
@end

@implementation SQKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupContextManager];
    
    return YES;
}

- (void)setupContextManager {
    if (!self.contextManager) {
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        self.contextManager = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType managedObjectModel:model];
    }
}

@end
```

For a SQLite based persistent store specify `NSSQLiteStoreType`. If you are writing unit tests that interact with Core Data, then a context manager with `NSInMemoryStoreType` is useful as changes are not persisted between test suite runs, and side effects from your production SQLite database do not contaminate your tests.

If you only have a single Data Model then `[NSManagedObjectModel mergedModelFromBundles:nil]` will return this.

The context manager provides a convenient way to obtain 2 kinds of `NSManagedObjectContext` objects that are commonly used.

### Using the main context

There is only ever one main context and is obtained through the `mainContext` method. You should use this context for any interaction with Core Data while on the main thread, such as using controllers and UI objects that are required to be used only on the main thread.. This context is initialised with `NSMainQueueConcurrencyType`and should therefore only be used while on the main thread. 

**Do not use the main context while in a background thread.** Failure to use the main context on the main thread will result inconsistent behaviour and possible crashes. To safe guard this an exception will be thrown if you ask the context manager for the main context while on a thread that is not the main context.

### Using private contexts

Private contexts are initialised with `NSPrivateQueueConcurrencyType`. They are designed to  perform Core Data work off the main thread. There are several situations in which performing operations with Core Data on a background thread or queue is beneficial, in particular if you want to ensure that your application’s user interface remains responsive while Core Data is undertaking a long-running task. 

Obtain a private context from the `newPrivateContext` method. This will create a new private context based on the current state of the persistent store. Conceptually you can think of the main context being "branched" into another (private) context. **When you have a new private context you should only use it on the thread on which is was created.**

Any work you perform with the private context, and any changes you make, stay independent to the state of the main context. When you save a private context your SQKContextManager instance will listen for the save notification and merge the changes back into the main context on your behalf. UI controllers and object using the main context will then get these updates automatically.

Make sure to retain the private context in a property. To quote the Apple Doc:

> Managed objects know what managed object context they’re associated with, and managed object contexts know what managed objects they contain. By default, though, the references between a managed object and its context are weak. This means that in general you cannot rely on a context to ensure the longevity of a managed object instance, and you cannot rely on the existence of a managed object to ensure the longevity of a context. Put another way, just because you fetched an object doesn’t mean it will stay around.

Note: the main context is retained by the context manager, unlike new private contexts which **you** have the responsibility of retaining.

### Automatic Merging

By default, any changes made in a private context are merged into the main context when the private context is saved. If you need to disable this for any reason you can set `shouldMergeOnSave` to NO. It will then be your responsibility to merge the changes when is appropriate for your use case.

```
self.privateContext = [self.contextManager newPrivateContext];
Self.privateContext.shouldMergeOnSave = NO;
```

### Concurrency 

Quoting the Apple Doc for 

> Core Data uses thread (or serialized queue) confinement to protect managed objects and managed object contexts (see “Concurrency with Core Data”). A consequence of this is that a context assumes the default owner is the thread or queue that allocated it—this is determined by the thread that calls its init method. You should not, therefore, initialize a context on one thread then pass it to a different thread. Instead, you should pass a reference to a persistent store coordinator and have the receiving thread/queue create a new context derived from that. If you use NSOperation, you must create the context in main (for a serial queue) or start (for a concurrent queue).

When using SQKDataKit you do not need to pass a reference to a persistent store coordinator to each part of your app that uses Core Data. Simply pass an instance of the `SQKContextManager` as this maintains the persistent store coordinator. Ask the `SQKContextManager` for a `newPrivateContext:` from the thread / queue you intend to perform your Core Data work on. Make sure to only use the new private context on the thread on which is was created, otherwise you might end up with unintended side effects and / or crashes.


## `NSManagedObject+SQKAdditions`

Additions to `NSManagedObject` to reduce boilerplate and simplify common operations, such as creating a fetch request or inserting a new instance of an object. These methods never should never be called directly on NSManagedObject (e.g. `[NSManagedObject sqk_entityName]`), but instead only on subclasses.

Includes a method for optimised batch insert-or-update, a common pattern in apps when updating from a web service. This method codifies the pattern found in the Apple guide to [Implementing Find-or-Create Efficiently](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdImporting.html#//apple_ref/doc/uid/TP40003174-SW4). Usage (on a background queue):
 
	NSArray *dictArray = @[
	                   @{@"IDAnimal" : @"123", @"Name" : @"Cat", @"Age" : @10},
	                   @{@"IDAnimal" : @"456", @"Name" : @"Dog", @"Age" : @5},
	                   @{@"IDAnimal" : @"789", @"Name" : @"Mouse", @"Age" : @1}
	                   ];
	
	self.privateContext = [self.contextManager newPrivateContext];
	
	NSError *error = nil;
	[Animal SQK_insertOrUpdate:dictArray
	            uniqueModelKey:@"animalID"
	           uniqueRemoteKey:@"IDAnimal"
	       propertySetterBlock:^(NSDictionary *dictionary, id managedObject) {
	           Animal *animal = (Animal *)managedObject;
	           animal.name = dictionary[@"Name"];
	           animal.age = dictionary[@"Age"];
	       }
	            privateContext:self.privateContext
	                     error:&error];
	                     

## `SQKManagedObjectController`

It is important to keep track of any `NSManagedObjects` you have fetched. If you hold a reference to an object but it is deleted elsewhere (possibly as part of a background sync operation) then when you try to access it an exception will be raised and the app will probably crash. Maybe it is just edited in the background - but your detail view  doesn't know, so you're showing out of date information.

`NSFetchedResultsController` avoids these issues as it listens to Core Data notifications and keeps itself updated. If you need a Core Data backed tableview, always use an `NSFetchedResultsController` if you can.

In other situations an `NSFetchedResultsController` is a bit of a heavy solution.  An `SQKManagedObjectController` is like an FRC, but simpler - it manages the fetch request, holds onto the objects, and refreshes them on demand.

### Initialisation

```
NSFetchRequest *request = [Commit SQK_fetchRequest];
self.controller = [[SQKManagedObjectController alloc] initWithFetchRequest:request
                                                          managedObjectContext:[self.contextManager mainContext]];
[self.controller performFetch:&error];                                                        
```

Or if you already have objects you want to manage (say they are passed to a detail view):

```
SQKManagedObjectController *objectsController = [[SQKManagedObjectController alloc] initWithWithManagedObjects:[self.controller managedObjects]];
```

### Delegate
When objects are fetched (as a result of calling `performFetch:`), changed, inserted or deleted, the controller's delegate methods are called. These are:

```
-(void)controller:(SQKManagedObjectController*)controller
		fetchedObjects:(NSIndexSet*)fetchedObjectIndexes error:(NSError**)error;
```
```
-(void)controller:(SQKManagedObjectController*)controller
   		didSaveObjects:(NSIndexSet*)savedObjectIndexes;
```
```
-(void)controller:(SQKManagedObjectController*)controller
 		didInsertObjects:(NSIndexSet*)insertedObjectIndexes;
```
```
-(void)controller:(SQKManagedObjectController*)controller
  		didDeleteObjects:(NSIndexSet*)deletedObjectIndexes;
```

The index set contains the indexes of objects in `controller.managedObjects` which have been fetched, inserted, edited or deleted. The set of objects is automatically up-to-date by monitoring the save notifications - new objects that match the specified fetch request are added, existing ones are refreshed with `refreshObject:mergeChanges:`. It is then up to you to decide what to do with that information - for instance, update some visible data, or pop a view controller from the stack.

### Blocks

If you prefer blocks over delegates, you can set 
`fetchedObjectsBlock`, `savedObjectsBlock`, `insertedObjectsBlock`, and `deletedObjectsBlock` as well as or instead of the delegate. Be aware that if both are set, the delegate methods will be called first.

### Concurrency
In general this class is designed for use from the main thread only, using objects in a main thread context. Your mileage may vary in any other circumstances.

## `SQKFetchedTableViewController`

Above, I told you that you should be using `NSFetchedResultsController` if you have a Core Data backed table view. "But there's so much _boilerplate_!", you whinge. "If only there was a simpler way to create a Core Data-backed searchable, filterable UITableView Controller!".

`SQKFetchedTableViewController` provides a simpler way to replicate the often-used pattern of a searchable Core Data-backed table view. It must be subclassed.

See `SQKCommitsViewController` in the example project for an implementation.

### Usage

Subclass `SQKFetchedTableViewController` and override the following methods:

```
- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
```
This is where you configure a cell for display. You would then call this method from your own `tableView:cellForRowAtIndexPath:` method.

And: 

```
- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString;
```

Here you must return an `NSFetchRequest` for the specified search string. If searchString is nil, return your unfiltered dataset. This will be called multiple times as the user enters a search string.


### Section Indexes

To use a section index in a `SQKFetchedTableViewController` subclass:

```
- (NSString *)sectionKeyPathForSearchableFetchedResultsController:(SQKFetchedTableViewController *)controller 
{
    return @"uppercaseFirstLetterTitle"; // the sectionKeyPath
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    // No section indexes if searching
    if (self.searchIsActive) {
        return nil;
    }
    return self.sectionIndexes;
}

 (NSString *)tableView:(UITableView *)tableView
		titleForHeaderInSection:(NSInteger)section
{
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView
	sectionForSectionIndexTitle:(NSString *)title
               			atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}
```

## `SQKDataImportOperation`

Use an SQKDataImportOperation when you need to perform work with Core Data off the main thread. 

You need to subclass and must override the `performWorkPrivateContext:` method, which is where you should perform your work with Core Data. The operation will use it's `SQKContextManager` to obtain a private managed object context. This is passed to the `performWorkPrivateContext:` method for you to use. When your work is complete call the `completeOperationBySavingContext:` method passing in the private context you have used. This saves the (private) managed object context, merges the changes into main context, and finishes operation.

Add the operation to an NSOperationQueue that is not the `mainQueue` so that the computation is performed off the main thread. As a private context is used any insertions, updates, deletions etc **must be done in a background thread**, and using the correct operation queue will ensure that.

### Usage

How to subclass:

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

Using with an operation queue.

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

# Acknowledgements

* [SJODataKit](https://github.com/blork/SJODataKit)
* [SJOManagedObjectController](https://github.com/blork/SJOManagedObjectController)

# Licence

Copyright (c) 3Squared Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

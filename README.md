# SQKDataKit

Collection of classes to make working with Core Data easier and help DRY-up your own code. Provides convenience methods and classes for working in a multi-threaded environment with `NSManagedObject`s and `NSManagedObjectContext`s. Codifies some good practises for importing large data sets efficiently.

## Installation

* Using [Cocoapods](http://cocoapods.org), add `pod SQKDataKit` to you Podfile.
* `#import <SQKDataKit/SQKDataKit.h>` as necessary.


## Usage

### `SQKContextManager`

`SQKContextManager` is you first point of entry for using SQKDataKit. It creates and manages `NSManagedObjectContext` instances for you. 

#### Initialisation

You should only ever use a single `SQKContextManager` as it maintains the `NSPersistentStoreCoordinator` instance for your Core Data stack. It is recommended you create it during the initial load of the app, for example in your AppDelegate. Initalise a context manager with a concurrency type and a `NSManagedObjectModel`:

```
`#import <SQKDataKit/SQKDataKit.h>`

@interface SQKAppDelegate ()
@property (nonatomic, readwrite, strong) SQKContextManager *contextManager;
@end

@implementation SQKAppDelegate

- (SQKContextManager *)contextManager {
    if (!_contextManager) {
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        _contextManager = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType managedObjectModel:model];
    }
    return _contextManager;
}

@end
```

For a SQLite based persistent store specify `NSSQLiteStoreType`. If you are writing unit tests that interact with Core Data, then a context manager with the `NSInMemoryStoreType` is useful as changes are not persisted between test suit runs, and side effects from your production SQLite database do not effect tests.

If you only have a single Data Model then `[NSManagedObjectModel mergedModelFromBundles:nil]` will return this.


### `NSPersistentStoreCoordinator+SQKAdditions`

Todo

### `SQKDataImportOperation`

Todo

# Licence

Copyright (c) 3Squared Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
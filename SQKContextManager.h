// Provides an NSManagedObjectContext on the main thread, and generates a new private NSManagedObjectContext as needed.
@interface SQKContextManager : NSObject

// A string constant (such as NSSQLiteStoreType) that specifies the store type—see “Store Types” for possible values.
@property (nonatomic, strong) NSString *storeType;

// Block used to customise the NSPersistentStoreCoordinator instance when it is first created.
typedef void (^PersistentStoreCoordinatorCustomisationBlock)(NSPersistentStoreCoordinator *persistentStoreCoordinator);
@property (nonatomic, copy) PersistentStoreCoordinatorCustomisationBlock *persistentStoreCoordinatorCustomisationBlock;

// Saves the changes.
// Changes from any private contexts are merged into the main context at this point
- (void)save;

// For large data imports use a private context and SQKJSONDataImportOperation
- (NSManagedObjectContext *)newPrivateContext;

// For everthing else theres master card / main context
- (NSManagedObjectContext *)mainContext;

@end
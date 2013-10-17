// Provides an NSManagedObjectContext on the main thread, and generates a new private NSManagedObjectContext as needed.
@interface SQKContextManager : NSObject

// Initialise with a string constant (such as NSSQLiteStoreType) that specifies the store type—see “Store Types” for possible values.
- (instancetype)initWithStoreType:(NSString *)storeType;
- (instancetype)initWithStoreType:(NSString *)storeType managedObjectModel:(NSManagedObjectModel *)managedObjectModel 

// Saves the changes.
// Changes from any private contexts are merged into the main context at this point
- (BOOL)save:(NSError **)error;

// For large data imports use a private context and SQKJSONDataImportOperation
- (NSManagedObjectContext *)newPrivateContext;

// For everything else there's master card / main context
- (NSManagedObjectContext *)mainContext;

@end
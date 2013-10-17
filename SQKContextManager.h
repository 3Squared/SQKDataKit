// Provides an NSManagedObjectContext on the main thread, and generates a new private NSManagedObjectContext as needed.
@interface SQKContextManager : NSObject

// Contrcut with a string constant (such as NSSQLiteStoreType) that specifies the store type—see “Store Types” for possible values.
- (instancetype)initWithStoreType:(NSString *)storeType;

// Block used to customise the NSManagedObjectModel instance when it is first created.
typedef void (^SQKManagedObjectModelCustomisationBlock)(NSManagedObjectModel *managedObjectModel);
@property (nonatomic, copy) SQKManagedObjectModelCustomisationBlock *managedObjectModelCustomisationBlock;

// Saves the changes.
// Changes from any private contexts are merged into the main context at this point
- (BOOL)saveWithError:(NSError *)error;

// For large data imports use a private context and SQKJSONDataImportOperation
- (NSManagedObjectContext *)newPrivateContext;

// For everthing else theres master card / main context
- (NSManagedObjectContext *)mainContext;

@end
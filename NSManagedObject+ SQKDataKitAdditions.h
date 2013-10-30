//  A collection of useful helper methods on NSManagedObject to reduce boilerplate and simplify common operations.
@interface NSManagedObject (SQKDataKitAdditions)

// The name of the entity, derived from the class name.
+ (NSString *)SQK_entityName;

// A convenience method for obtaning a new NSEntityDescription.
+ (NSEntityDescription *)SQK_entityWithContext:(NSManagedObjectContext *)context;

// Insert a single MO
+ (instancetype)SQK_insertInContext:(NSManagedObjectContext *)context;

// Returns a fetch request configured for the entity.
+ (NSFetchRequest *)SQK_fetchRequest;

// Find a single MO based on a key and value or inserts one if one does not exist
+ (instancetype)SQK_findOrInsertByKey:(NSString *)key
                            value:(id)value
                        context:(NSManagedObjectContext *)context
                            error:(NSError **)error;

// Batch find or update
typedef void (^SQKPropertySetterBlock)(NSDictionary* dictionary, NSManagedObject *managedObject);
+ (void)SQK_insertOrUpdate:(NSArray *)dictArray
          uniqueModelKey:(NSString *)modelKey
         uniqueRemoteKey:(NSString *)remoteDataKey
   propertySetterBlock:(SQKPropertySetterBlock *)propertySetterBlock
             context:(NSManagedObjectContext *)context
                 error:(NSError **)error;


// Deletes the MO from the context it is currently in
- (BOOL)SQK_deleteObject:(NSError **)error;

// Deletes the MOs in the given context
+ (BOOL)SQK_deleteAllObjectsInContext:(NSManagedObjectContext *)context error:(NSError **)error;

// Convenience method for retrieving an NSPropertyDescription.
+ (NSPropertyDescription*)SQK_propertyDescriptionForName:(NSString *)name
                                           context:(NSManagedObjectContext *)context;

@end
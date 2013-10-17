//  A collection of useful helper methods on NSManagedObject to reduce boilerplate and simplify common operations.
@interface NSManagedObject (SQKDataKitAdditions)

// The name of the entity, derived from the class name.
+ (NSString *)entityName;

// A convenience method for obtaning a new NSEntityDescription.
+ (NSEntityDescription *)entityWithContext:(NSManagedObjectContext *)context;

// Insert a single MO
+ (instancetype)insertInContext:(NSManagedObjectContext *)context;

// Returns a fetch request configured for the entity.
+ (NSFetchRequest *)fetchRequest;

// Find a single MO based on a key and value or inserts one if one does not exist
+ (instancetype)findOrInsertByKey:(NSString *)key
                            value:(id)value
                        context:(NSManagedObjectContext *)context
                            error:(NSError **)error;

// Batch find or update
typedef void (^SQKPropertySetterBlock)(NSDictionary* dictionary, NSManagedObject *managedObject);
+ (void)insertOrUpdate:(NSArray *)dictArray
          uniqueModelKey:(NSString *)modelKey
         uniqueRemoteKey:(NSString *)remoteDataKey
   propertySetterBlock:(SQKPropertySetterBlock *)propertySetterBlock
             context:(NSManagedObjectContext *)context
                 error:(NSError **)error;


// Deletes the MO from the context it is currently in
- (BOOL)deleteObject:(NSError **)error;

// Deletes the MOs in the given context
+ (BOOL)deleteAllObjectsInContext:(NSManagedObjectContext *)context error:(NSError **)error;

// Convenience method for retrieving an NSPropertyDescription.
+ (NSPropertyDescription*)propertyDescriptionForName:(NSString *)name
                                           context:(NSManagedObjectContext *)context;

@end
//  A collection of useful helper methods on NSManagedObject to reduce boilerplate and simplify common operations.
@interface NSManagedObject (SQKDataKitAdditions)

// The name of the entity, derived from the class name.
+ (NSString *)entityName;

// A convenience method for obtaning a new NSEntityDescription.
+ (NSEntityDescription *)entityWithContext:(NSManagedObjectContext *)context;

// Insert a single MO
+ (instancetype)insertInContext:(NSManagedObjectContext*)context;

// Find a single MO based on a key and value
+ (instancetype)findByKey:(NSString *)key value:(id)value inContext:(NSManagedObjectContext *)context;
+ (instancetype)findByKey:(NSString *)key value:(id)value inContext:(NSManagedObjectContext *)context error:(NSError **)error;

// Returns a fetch request configured for the entity.
+ (NSFetchRequest *)fetchRequest;

//  Returns a fetch request configured for the entity with the given predicate.
+ (NSFetchRequest *)fetchRequestWithPredicate:(NSPredicate *)predicate;

//  Returns the result of executing a fetch request the given predicate in the given context.
+ (NSArray *)executeFetchRequestWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (NSArray *)executeFetchRequestWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context error:(NSError **)error;

// Find a single MO based on a key and value or inserts one if one does not exist
]+ (instancetype)findOrInsertByKey:(NSString *)key value:(id)value inContext:(NSManagedObjectContext *)context;
+ (instancetype)findOrInsertByKey:(NSString *)key value:(id)value inContext:(NSManagedObjectContext *)context error:(NSError **)error;

// Batch find or update
typedef void (^PropertySetter)(NSDictionary* dictionary, id managedObject);
+ (void)insertOrUpdate:(NSArray *)dictArray
          forUniqueKey:(NSString *)key
    withPropertySetter:(PropertySetter *)propertySetter;
               inContext:(NSManagedObjectContext *)context;

+ (void)insertOrUpdate:(NSArray *)dictArray
          forUniqueKey:(NSString *)key
    withPropertySetter:(PropertySetter *)propertySetter;
               inContext:(NSManagedObjectContext *)context
                 error:(NSError *)error;


// Deletes the MO from the context it is currently in
- (void)delete;;
- (void)deleteUsingError:(NSError *)error;

// Deletes the MOs in the given context
+ (void)deleteAllInContext:(NSManagedObjectContext *)context;
+ (void)deleteAllInContext:(NSManagedObjectContext *)context error:(NSError **)error;

// Convenience method for retrieving an NSPropertyDescription.
+ (NSPropertyDescription*)propertyDescriptionForName:(NSString* )name inContext:(NSManagedObjectContext *)context;

@end
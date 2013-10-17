// An NSOperation for you to subclass when you need to import JSON data off of the main thread.
@interface SQKJSONDataImportOperation : NSOperation
@property (nonatomic, strong) NSManagedObjectContext *privateContext;
@property (nonatomic, strong) id json;

- (id)initWithPrivateContext:(NSManagedObjectContext *)context json:(id)json;

// Must overide in subclass
- (void)importJSON:(id) intoContext:(NSManagedObjectContext *)context;

@end
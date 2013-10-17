// An NSOperation for you to subclass when you need to import JSON data off of the main thread.
@interface SQKJSONDataImportOperation : NSOperation
@property (nonatomic, strong, readonly) NSManagedObjectContext *privateContext;
@property (nonatomic, strong, readonly) id json;

- (id)initWithJSON:(id)json privateContext:(NSManagedObjectContext *)context;

// Must overide in subclass
- (void)importJSON:(id)json privateContext:(NSManagedObjectContext *)context;

@end
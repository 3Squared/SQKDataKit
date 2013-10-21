// An NSOperation for you to subclass when you need to import JSON data off of the main thread.
@interface SQKJSONDataImportOperation : NSOperation
@property (nonatomic, readonly) NSManagedObjectContext *privateContext;
@property (nonatomic, readonly) id json;

- (instancetype)initWithPrivateContext:(NSManagedObjectContext *)context json:(id)json;

// Must overide in subclass
- (void)updatePrivateContext:(NSManagedObjectContext *)context usingJSON:(id)json;

@end
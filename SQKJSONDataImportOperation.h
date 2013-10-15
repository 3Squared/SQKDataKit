// An NSOperation for you subclass when you need to import JSON data off of the main thread.
@interface SQKJSONDataImportOperation : NSOperation
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) id jsonData;

- (id)initWithContext:(NSManagedObjectContext *)context jsonData:(id)jsonData;

// Must overide in subclass
- (void)import

@end
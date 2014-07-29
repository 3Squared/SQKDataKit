//
//  CDODataImporter.m
//
//
//  Created by Luke Stringer on 28/07/2014.
//
//

#import "CDODataImporter.h"

@interface CDODataImporter ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@end

@implementation CDODataImporter

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	if (self = [super init]) {
		self.managedObjectContext = managedObjectContext;
	}
	return self;
}

- (void)importJSON:(NSArray *)JSON {
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
            reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
            userInfo:nil];
}

@end

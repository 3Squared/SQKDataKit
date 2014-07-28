//
//  CDOCommitImporter.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 27/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "CDOCommitImporter.h"
#import "NSManagedObject+SQKAdditions.h"
#import "Commit.h"

@interface CDOCommitImporter ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@end

@implementation CDOCommitImporter

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	if (self = [super init]) {
		self.managedObjectContext = managedObjectContext;
	}
	return self;
}

- (void)importJSON:(NSArray *)JSON {
	[Commit sqk_insertOrUpdate:JSON
                uniqueModelKey:@"sha"
               uniqueRemoteKey:@"sha"
           propertySetterBlock:^(NSDictionary *dictionary, Commit *commit) {
               commit.message = dictionary[@"commit"][@"message"];
           }
                privateContext:self.managedObjectContext error:NULL];
}

@end

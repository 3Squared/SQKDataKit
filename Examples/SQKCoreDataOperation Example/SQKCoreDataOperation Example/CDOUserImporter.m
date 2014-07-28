//
//  CDOUserImporter.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "CDOUserImporter.h"
#import "NSManagedObject+SQKAdditions.h"
#import "User.h"

@implementation CDOUserImporter

- (void)importJSON:(NSArray *)JSON {
    [User sqk_insertOrUpdate:JSON
	            uniqueModelKey:@"username"
	           uniqueRemoteKey:@"login"
	       propertySetterBlock: ^(NSDictionary *dictionary, Commit *commit) {
               // TODO
           } privateContext:self.managedObjectContext error:NULL];
}

@end

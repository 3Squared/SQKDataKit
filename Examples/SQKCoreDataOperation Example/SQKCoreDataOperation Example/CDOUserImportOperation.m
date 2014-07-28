//
//  CDOUserImportOperation.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "CDOUserImportOperation.h"
#import "CDOGithubAPIClient.h"
#import "CDOUserImporter.h"
#import "NSManagedObject+SQKAdditions.h"
#import "User.h"

@interface CDOUserImportOperation ()
@property (nonatomic, strong) NSError *operationError;
@end

@implementation CDOUserImportOperation

- (void)performWorkPrivateContext:(NSManagedObjectContext *)context {
	NSMutableArray *usersJSON = [NSMutableArray array];

	NSFetchRequest *fetchRequest = [User sqk_fetchRequest];
	NSArray *users = [context executeFetchRequest:fetchRequest error:NULL];

	if (users.count > 0) {
		for (User *user in users) {
			id JSON = [[CDOGithubAPIClient sharedInstance] getUser:user.username error:NULL];
			[usersJSON addObject:JSON];
		}
		CDOUserImporter *importer = [[CDOUserImporter alloc] initWithManagedObjectContext:context];
		[importer importJSON:usersJSON];
		[self completeOperationBySavingContext:context];
	}
	else {
		[self completeOperationBySavingContext:context];
	}
}

- (NSError *)error {
    return self.operationError;
}

@end

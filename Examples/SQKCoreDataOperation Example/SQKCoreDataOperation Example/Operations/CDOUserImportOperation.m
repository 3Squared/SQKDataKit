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
@property (nonatomic, strong) CDOGithubAPIClient *APIClient;
@end

@implementation CDOUserImportOperation


- (instancetype)initWithContextManager:(SQKContextManager *)contextManager APIClient:(CDOGithubAPIClient *)APIClient
{
    self = [super initWithContextManager:contextManager];
    if (self) {
        self.APIClient = APIClient;
    }
    return self;
}

- (void)performWorkWithPrivateContext:(NSManagedObjectContext *)context {
	NSLog(@"Executing %@", NSStringFromClass([self class]));

	NSMutableArray *usersJSON = [NSMutableArray array];

	NSFetchRequest *fetchRequest = [User sqk_fetchRequest];
	NSArray *users = [context executeFetchRequest:fetchRequest error:NULL];

	if (users.count > 0) {
		for (User *user in users) {
			id JSON = [self.APIClient getUser:user.username error:NULL];
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

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
#import "User.h"

@implementation CDOCommitImporter

- (void)importJSON:(NSArray *)JSON
{
    [Commit sqk_insertOrUpdate:JSON
                uniqueModelKey:@"sha"
               uniqueRemoteKey:@"sha"
           propertySetterBlock:^(NSDictionary *dictionary, Commit *commit) {
                    commit.message = dictionary[@"commit"][@"message"];
           } privateContext:self.managedObjectContext
                         error:NULL];

    /**
	 *  Import 'stub' User entities with only the username set.
	 *  The rest of the properties will be set later.
	 */
    NSSet *usernames = [NSSet setWithArray:[JSON valueForKeyPath:@"committer.login"]];
    for (NSString *username in usernames)
    {
        if (username != (id)[NSNull null])
        {
            [User sqk_insertOrFetchWithKey:@"username" value:username context:self.managedObjectContext error:NULL];
        }
    }
}

@end

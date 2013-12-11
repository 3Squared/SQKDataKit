//
//  DataImportOperation.m
//  SQKDataKit
//
//  Created by Luke Stringer on 10/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "DataImportOperation.h"
#import "Commit.h"
#import "NSManagedObject+SQKAdditions.h"

@implementation DataImportOperation

- (void)updatePrivateContext:(NSManagedObjectContext *)context usingJSON:(id)json {
    [Commit SQK_insertOrUpdate:json
                uniqueModelKey:@"sha"
               uniqueRemoteKey:@"sha"
           propertySetterBlock:^(NSDictionary *dictionary, Commit *commit) {
               commit.authorName = dictionary[@"commit"][@"committer"][@"name"];
               commit.authorEmail = dictionary[@"commit"][@"committer"][@"email"];
               commit.message = dictionary[@"commit"][@"message"];
           }
                privateContext:context
                         error:nil];
}

@end

//
//  NaiveImportOperation.m
//  SQKDataKit
//
//  Created by Luke Stringer on 12/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "NaiveImportOperation.h"
#import "Commit.h"
#import "NSManagedObject+SQKAdditions.h"

@interface NaiveImportOperation ()
@property (nonatomic, strong, readwrite) NSDate *startDate;
@end

@implementation NaiveImportOperation

- (void)performWorkPrivateContext:(NSManagedObjectContext *)context usingData:(id)data
{
    self.startDate = [NSDate date];
    [data enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
        NSFetchRequest *fetchRequest = [Commit sqk_fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"sha == %@", dictionary[@"sha"]];
        fetchRequest.fetchLimit = 1;
        NSArray *objects = [context executeFetchRequest:fetchRequest error:nil];
        Commit *commit = [objects lastObject];
        if (!commit)
        {
            commit = [Commit sqk_insertInContext:context];
            commit.sha = dictionary[@"sha"];
            commit.authorName = dictionary[@"commit"][@"committer"][@"name"];
            commit.authorEmail = dictionary[@"commit"][@"committer"][@"email"];
            commit.date = [self dateFromJSONString:dictionary[@"commit"][@"committer"][@"date"]];
            commit.message = dictionary[@"commit"][@"message"];
            commit.url = dictionary[@"html_url"];
        }
    }];
    [self completeOperationBySavingContext:context];
}

- (NSDate *)dateFromJSONString:(NSString *)jsonString
{
    NSDate *date = [[self dateFormatter] dateFromString:jsonString];
    return date;
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    return dateFormatter;
}

@end

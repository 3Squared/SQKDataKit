//
//  DataImportOperation.m
//  SQKDataKit
//
//  Created by Luke Stringer on 10/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "OptimisedImportOperation.h"
#import "Commit.h"
#import "NSManagedObject+SQKAdditions.h"

@interface OptimisedImportOperation ()
@property (nonatomic, strong, readwrite) NSDate *startDate;
@end

@implementation OptimisedImportOperation

- (void)performWorkPrivateContext:(NSManagedObjectContext *)context usingData:(id)data
{
    self.startDate = [NSDate date];
    [Commit sqk_insertOrUpdate:data
                uniqueModelKey:@"sha"
               uniqueRemoteKey:@"sha"
           propertySetterBlock:^(NSDictionary *dictionary, Commit *commit) {

               NSString *authorName = dictionary[@"commit"][@"committer"][@"name"];
               if (![commit.authorName isEqualToString:authorName])
               {
                   commit.authorName = authorName;
               }

               NSString *authorEmail = dictionary[@"commit"][@"committer"][@"email"];
               if (![commit.authorEmail isEqualToString:authorEmail])
               {
                   commit.authorEmail = authorEmail;
               }

               NSDate *date =
                   [self dateFromJSONString:dictionary[@"commit"][@"committer"][@"date"]];
               if (![commit.date isEqualToDate:date])
               {
                   commit.date = date;
               }

               NSString *message = dictionary[@"commit"][@"message"];
               if (![commit.message isEqualToString:message])
               {
                   commit.message = dictionary[@"commit"][@"message"];
               }

               NSString *url = dictionary[@"html_url"];
               if (![commit.url isEqualToString:url])
               {
                   commit.url = dictionary[@"html_url"];
               }
           } privateContext:context
                         error:nil];
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

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
    NSDate *beforeDate = [NSDate date];
    
    [Commit SQK_insertOrUpdate:json
                uniqueModelKey:@"sha"
               uniqueRemoteKey:@"sha"
           propertySetterBlock:^(NSDictionary *dictionary, Commit *commit) {
               commit.authorName = dictionary[@"commit"][@"committer"][@"name"];
               commit.authorEmail = dictionary[@"commit"][@"committer"][@"email"];
               commit.date = [self dateFromJSONString:dictionary[@"commit"][@"committer"][@"date"]];
               commit.message = dictionary[@"commit"][@"message"];
               commit.url = dictionary[@"html_url"];
           }
                privateContext:context
                         error:nil];
    
     NSLog(@"Time taken: %f", [[NSDate date] timeIntervalSinceDate:beforeDate]);
}

- (NSDate *)dateFromJSONString:(NSString *)jsonString {
    NSDate *date = [[self dateFormatter] dateFromString:jsonString];
    return date;
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    return dateFormatter;
}

@end

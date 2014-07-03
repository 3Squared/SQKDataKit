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

- (void)updateContext:(NSManagedObjectContext *)context usingData:(id)data {
    self.startDate = [NSDate date];
    [Commit sqk_insertOrUpdate:data
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
    [context save:nil];
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

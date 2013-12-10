//
//  DataImportOperation.m
//  SQKDataKit
//
//  Created by Luke Stringer on 10/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "DataImportOperation.h"

@implementation DataImportOperation

- (void)updatePrivateContext:(NSManagedObjectContext *)context usingJSON:(id)json {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions
                                                  error:nil];
    
    NSLog(@"%@", result);
}

@end

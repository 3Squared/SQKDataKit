//
//  SQKJSONLoader.m
//  SQKDataKit
//
//  Created by Luke Stringer on 23/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKJSONLoader.h"

@implementation SQKJSONLoader

+ (id)loadJSONFileName:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:kNilOptions
                                             error:nil];
}

@end

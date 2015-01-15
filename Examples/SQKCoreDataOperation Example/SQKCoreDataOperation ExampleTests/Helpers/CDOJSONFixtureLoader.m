//
//  CDOJSONFixtureLoader.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 27/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "CDOJSONFixtureLoader.h"

@implementation CDOJSONFixtureLoader

+ (id)loadJSONFileNamed:(NSString *)fileName
{
    NSString *filepath = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end

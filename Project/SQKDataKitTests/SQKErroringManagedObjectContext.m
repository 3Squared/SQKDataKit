//
//  SQKErroringManagedObjectContext.m
//  SQKDataKit
//
//  Created by Luke Stringer on 11/06/2015.
//  Copyright (c) 2015 3Squared. All rights reserved.
//

#import "SQKErroringManagedObjectContext.h"

@implementation SQKErroringManagedObjectContext

- (BOOL)save:(NSError *__autoreleasing *)error
{
	*error = [NSError errorWithDomain:@"SQKErroringManagedObjectContext" code:0 userInfo:nil];
	return NO;
}

@end

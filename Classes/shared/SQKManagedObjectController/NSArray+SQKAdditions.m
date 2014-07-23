//
//  NSArray+SJOIndexSet.m
//  SJOManagedObjectController
//
//  Created by Sam Oakley on 22/03/2014.
//  Copyright (c) 2014 Sam Oakley. All rights reserved.
//

#import "NSArray+SQKAdditions.h"

@implementation NSArray (SQKAdditions)

- (NSIndexSet *)sqk_indexesOfObjects
{
    return
        [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) { return YES; }];
}

@end

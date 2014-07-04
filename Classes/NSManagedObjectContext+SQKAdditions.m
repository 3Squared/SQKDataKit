//
//  NSManagedObjectContext+SQKAdditions.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/07/2014.
//  Copyright (c) 2014 3Squared. All rights reserved.
//

#import "NSManagedObjectContext+SQKAdditions.h"
#import <objc/runtime.h>

@implementation NSManagedObjectContext (SQKAdditions)
@dynamic shouldMergeOnSave;

- (BOOL)shouldMergeOnSave {
    NSNumber *wrappedBool = objc_getAssociatedObject(self, @selector(shouldMergeOnSave));
    return [wrappedBool boolValue];
}

- (void)setShouldMergeOnSave:(BOOL)shouldMergeOnSave {
    NSNumber *wrappedBool = @(shouldMergeOnSave);
    objc_setAssociatedObject(self, @selector(shouldMergeOnSave), wrappedBool, OBJC_ASSOCIATION_ASSIGN);
}

@end

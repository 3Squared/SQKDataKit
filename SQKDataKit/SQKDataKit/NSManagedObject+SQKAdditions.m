//
//  NSManagedObject+SQKAdditions.m
//  SQKDataKit
//
//  Created by Luke Stringer on 05/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "NSManagedObject+SQKAdditions.h"

@implementation NSManagedObject (SQKAdditions)

+ (NSString *)SQK_entityName {
    return NSStringFromClass([self class]);
}

+ (NSEntityDescription *)SQK_entityDescriptionInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:[self SQK_entityName] inManagedObjectContext:context];
}

@end

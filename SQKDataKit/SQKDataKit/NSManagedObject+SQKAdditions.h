//
//  NSManagedObject+SQKAdditions.h
//  SQKDataKit
//
//  Created by Luke Stringer on 05/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (SQKAdditions)

+ (NSString *)SQK_entityName;

+ (NSEntityDescription *)SQK_entityDescriptionInContext:(NSManagedObjectContext *)context;

@end

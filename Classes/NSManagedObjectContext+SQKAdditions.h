//
//  NSManagedObjectContext+SQKAdditions.h
//  SQKDataKit
//
//  Created by Luke Stringer on 04/07/2014.
//  Copyright (c) 2014 3Squared. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (SQKAdditions)

/**
 *  If set to YES SQKContextManager will merge changes into the main context automatically on save. 
 *  If set to NO it is your responsibility to merge the changes when is appropriate for your user case.
 *  Default value is NO.
 */
@property (nonatomic, assign) BOOL shouldMergeOnSave;

@end

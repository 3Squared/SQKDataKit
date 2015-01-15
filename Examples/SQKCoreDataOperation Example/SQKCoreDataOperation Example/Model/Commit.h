//
//  Commit.h
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 27/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Commit : NSManagedObject

@property (nonatomic, retain) NSString *sha;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSManagedObject *commiter;

@end

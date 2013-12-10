//
//  Commit.h
//  SQKDataKit
//
//  Created by Luke Stringer on 10/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Commit : NSManagedObject

@property (nonatomic, retain) NSString * sha;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSDate * authorEmail;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * url;

@end

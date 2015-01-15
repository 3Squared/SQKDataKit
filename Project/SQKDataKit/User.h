//
//  User.h
//  SQKDataKit
//
//  Created by Sam Oakley on 09/09/2014.
//  Copyright (c) 2014 3Squared. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface User : NSManagedObject

@property (nonatomic, retain) NSString *name;

@end

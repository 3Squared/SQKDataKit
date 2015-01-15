//
//  User.h
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 27/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Commit;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSNumber *followers;
@property (nonatomic, retain) NSString *avatarURL;
@property (nonatomic, retain) NSNumber *following;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSSet *commits;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCommitsObject:(Commit *)value;
- (void)removeCommitsObject:(Commit *)value;
- (void)addCommits:(NSSet *)values;
- (void)removeCommits:(NSSet *)values;

@end

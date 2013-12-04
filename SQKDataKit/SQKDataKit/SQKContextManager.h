//
//  SQKContextManager.h
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SQKContextManager : NSObject

@property (nonatomic, readonly) NSString *storeType;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;

- (instancetype)initWithStoreType:(NSString *)storeType;
- (instancetype)initWithStoreType:(NSString *)storeType managedObjectModel:(NSManagedObjectModel *)managedObjectModel;

- (NSManagedObjectContext *)mainContext;
- (NSManagedObjectContext*) newPrivateContext;

@end

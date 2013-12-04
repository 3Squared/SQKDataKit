//
//  SQKContextManager.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKContextManager.h"

@interface SQKContextManager ()
@property (nonatomic, strong, readwrite) NSString *storeType;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@end

@implementation SQKContextManager

- (instancetype)init {
    return [self initWithStoreType:NSSQLiteStoreType];
}

- (instancetype)initWithStoreType:(NSString *)storeType {
    return [self initWithStoreType:NSSQLiteStoreType managedObjectModel:nil];
}

- (instancetype)initWithStoreType:(NSString *)storeType managedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    self = [super init];
    if (self) {
        self.storeType = storeType;
        self.managedObjectModel = managedObjectModel;
    }
    return self;
}


@end

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
@property (nonatomic, strong, readwrite) NSManagedObjectContext* mainContext;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@end

@implementation SQKContextManager

- (instancetype)init {
    return [self initWithStoreType:NSSQLiteStoreType];
}

- (instancetype)initWithStoreType:(NSString *)storeType {
    if (storeType) {
        return [self initWithStoreType:storeType managedObjectModel:nil];
    }
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

- (NSManagedObjectContext *)mainContext {
    if (_mainContext != nil) {
        return _mainContext;
    }
    
    _mainContext = [[NSManagedObjectContext alloc] init];
    return _mainContext;
}



@end

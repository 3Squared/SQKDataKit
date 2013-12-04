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
@end

@implementation SQKContextManager

- (instancetype)initWithStoreType:(NSString *)storeType {
    self = [super init];
    if (self) {
        self.storeType = storeType;
    }
    return self;
}

- (instancetype)init {
    return [self initWithStoreType:NSSQLiteStoreType];
}


@end

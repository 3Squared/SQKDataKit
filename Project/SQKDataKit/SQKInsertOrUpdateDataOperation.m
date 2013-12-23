//
//  SQKInsertOrUpdateDataOperation.m
//  SQKDataKit
//
//  Created by Sam Oakley on 18/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKInsertOrUpdateDataOperation.h"
#import "Commit.h"
#import "NSManagedObject+SQKAdditions.h"

@interface SQKInsertOrUpdateDataOperation ()
@property (nonatomic, strong, readwrite) NSString *uniqueModelKey;
@property (nonatomic, strong, readwrite) NSString *uniqueRemoteKey;
@property (nonatomic, assign, readwrite) SQKPropertySetterBlock propertySetterBlock;
@end

@implementation SQKInsertOrUpdateDataOperation

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager data:(id)data uniqueModelKey:(NSString*)uniqueModelKey uniqueRemoteKey:(NSString*)uniqueRemoteKey propertySetterBlock:(SQKPropertySetterBlock)propertySetterBlock {
    self = [super initWithContextManager:contextManager data:data];
    if (self) {
        _uniqueModelKey = uniqueModelKey;
        _uniqueRemoteKey = uniqueRemoteKey;
        _propertySetterBlock = propertySetterBlock;
    }
    return self;
}


- (void)updateContext:(NSManagedObjectContext *)context usingData:(id)json {
    [Commit SQK_insertOrUpdate:json
                uniqueModelKey:self.uniqueModelKey
               uniqueRemoteKey:self.uniqueRemoteKey
           propertySetterBlock:self.propertySetterBlock
                privateContext:context
                         error:nil];
    [context save:nil];
}

@end

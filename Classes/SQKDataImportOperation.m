//
//  SQKJSONDataImportOperation.m
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKDataImportOperation.h"
#import "SQKContextManager.h"

@interface SQKDataImportOperation ()
@property (nonatomic, strong, readwrite) SQKContextManager *contextManager;
@property (nonatomic, strong, readwrite) id data;
@end

@implementation SQKDataImportOperation

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager data:(id)data {
    self = [super init];
    if (self) {
        self.contextManager = contextManager;
        self.data = data;
    }
    return self;
}

- (void)updatePrivateContext:(NSManagedObjectContext *)context usingData:(id)data {
     @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)main {
    NSManagedObjectContext *context = [self.contextManager newPrivateContext];
    [context performBlockAndWait:^{
        [self updatePrivateContext:context usingData:self.data];
    }];
}

@end

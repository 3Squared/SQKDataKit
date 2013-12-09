//
//  SQKJSONDataImportOperation.m
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKJSONDataImportOperation.h"

@interface SQKJSONDataImportOperation ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext *privateContext;
@property (nonatomic, strong, readwrite) id json;

@end

@implementation SQKJSONDataImportOperation

- (instancetype)initWithPrivateContext:(NSManagedObjectContext *)context json:(id)json {
    self = [super init];
    if (self) {
        self.privateContext = context;
        self.json = json;
    }
    return self;
}

- (void)updatePrivateContext:(NSManagedObjectContext *)context usingJSON:(id)json {
     @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)main {
    [self updatePrivateContext:self.privateContext usingJSON:self.json];
}

@end

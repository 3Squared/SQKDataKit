//
//  GitDataImportOperation.m
//  SQKDataKit
//
//  Created by Luke Stringer on 13/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "GitDataImportOperation.h"

@interface GitDataImportOperation ()
@property (nonatomic, strong, readwrite) NSDate *startDate;
@property (nonatomic, strong) id data;
@end

@implementation GitDataImportOperation

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager data:(id)data
{
    if (self = [super initWithContextManager:contextManager])
    {
        self.data = data;
    }
    return self;
}

- (void)performWorkWithPrivateContext:(NSManagedObjectContext *)context
{
    [self performWorkWithPrivateContext:context usingData:self.data];
}

- (void)performWorkWithPrivateContext:(NSManagedObjectContext *)context usingData:(id)data
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end

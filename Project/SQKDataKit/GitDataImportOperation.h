//
//  GitDataImportOperation.h
//  SQKDataKit
//
//  Created by Luke Stringer on 13/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKCoreDataOperation.h"

@interface GitDataImportOperation : SQKCoreDataOperation

@property (nonatomic, readonly) NSDate *startDate;

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager data:(id)data;

- (void)performWorkPrivateContext:(NSManagedObjectContext *)context usingData:(id)data;

@end

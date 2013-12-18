//
//  SQKJSONDataImportOperation.h
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQKContextManager;
@interface SQKDataImportOperation : NSOperation

@property (nonatomic, readonly) SQKContextManager *contextManager;
@property (nonatomic, readonly) id data;

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager data:(id)data;

- (void)updatePrivateContext:(NSManagedObjectContext *)context usingData:(id)data;

@end

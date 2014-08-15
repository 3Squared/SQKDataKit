//
//  CDODataSychroniser.h
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQKContextManager;
@interface CDODataSynchroniser : NSObject

@property (nonatomic, strong, readonly) SQKContextManager *contextManager;
@property (nonatomic, assign, readonly) BOOL isSynchronising;

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager;

/**
 *  Synchronises now, or if currently synchronising queues up another synchronise to occur after the current synchronise finishes.
 */
- (void)synchronise;


@end

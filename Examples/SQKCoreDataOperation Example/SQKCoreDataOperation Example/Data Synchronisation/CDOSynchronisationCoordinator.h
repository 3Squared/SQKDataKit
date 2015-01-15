//
//  CDODataSychroniser.h
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CDOSynchronisationRequestNotification;
extern NSString * const CDOSynchronisationResponseNotification;

@class SQKContextManager, CDOGithubAPIClient;
@interface CDOSynchronisationCoordinator : NSObject

@property (nonatomic, strong, readonly) SQKContextManager *contextManager;

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager APIClient:(CDOGithubAPIClient *)APIClient;

+ (void)synchronise;

@end

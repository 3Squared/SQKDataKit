//
//  CDOUserImportOperation.h
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "SQKCoreDataOperation.h"

@class CDOGithubAPIClient;
@interface CDOUserImportOperation : SQKCoreDataOperation

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager APIClient:(CDOGithubAPIClient *)APIClient;

@end

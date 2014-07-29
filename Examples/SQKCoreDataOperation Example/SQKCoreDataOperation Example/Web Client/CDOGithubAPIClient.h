//
//  CDOGithubAPIClient.h
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 27/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDOGithubAPIClient : NSObject

@property (nonatomic, strong) NSString *accessToken;

+ (CDOGithubAPIClient *)sharedInstance;

- (id)getCommitsForRepo:(NSString *)repoName error:(NSError **)error;
- (id)getUser:(NSString *)username error:(NSError **)error;

@end

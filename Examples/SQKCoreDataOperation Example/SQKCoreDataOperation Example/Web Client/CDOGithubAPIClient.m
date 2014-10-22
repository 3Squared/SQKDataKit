//
//  CDOGithubAPIClient.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 27/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "CDOGithubAPIClient.h"

static NSString *const CDOHBaseURL = @"https://api.github.com";
static NSString *const CDOGithubAPIClientErrorDomain = @"com.3squared.CDOGithubAPIClientErrorDomain";

@interface CDOGithubAPIClient ()
@property (nonatomic, strong) NSString *accessToken;
@end

@implementation CDOGithubAPIClient

#pragma mark - Public

- (instancetype)initWithAccessToken:(NSString *)accessToken
{
    self = [super init];
    if (self) {
        self.accessToken = accessToken;
    }
    return self;
}

- (id)getCommitsForRepo:(NSString *)repoName error:(NSError **)error {
	NSString *endpoint = [NSString stringWithFormat:@"repos/3squared/%@/commits", repoName];
	NSURLRequest *request = [self requestForAPIEndpoint:endpoint webMethod:@"GET"];
	return [self sendSynchronousRequest:request error:error];
}

- (id)getUser:(NSString *)username error:(NSError **)error {
	NSString *endpoint = [NSString stringWithFormat:@"users/%@", username];
	NSURLRequest *request = [self requestForAPIEndpoint:endpoint webMethod:@"GET"];
	return [self sendSynchronousRequest:request error:error];
}

#pragma mark - Private

- (NSURLRequest *)requestForAPIEndpoint:(NSString *)urlString webMethod:(NSString *)webMethod {
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", CDOHBaseURL, urlString]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
	[request setValue:[NSString stringWithFormat:@"token %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
	[request setHTTPMethod:webMethod];
	return request;
}

- (id)sendSynchronousRequest:(NSURLRequest *)request error:(NSError **)error {
	NSLog(@"Github API call: %@", [[request URL] absoluteString]);

	NSHTTPURLResponse *response = nil;
	NSError *localError;
	NSData *reponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&localError];

	id JSON = reponseData != nil ? [NSJSONSerialization JSONObjectWithData:reponseData options:0 error:NULL] : nil;

	if (error) {
		if ((response != nil && [response statusCode] != 200)) {
			*error = [NSError errorWithDomain:CDOGithubAPIClientErrorDomain
			                             code:[response statusCode]
			                         userInfo:nil];
		}
		else {
			*error = localError;
		}
	}

	return JSON;
}

@end

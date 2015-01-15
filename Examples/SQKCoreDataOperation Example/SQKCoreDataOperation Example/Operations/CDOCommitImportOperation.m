//
//  CDOCommitImportOperation.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "CDOCommitImportOperation.h"
#import "CDOGithubAPIClient.h"
#import "CDOCommitImporter.h"

@interface CDOCommitImportOperation ()
@property (nonatomic, strong) NSError *operationError;
@property (nonatomic, strong) CDOGithubAPIClient *APIClient;
@end

@implementation CDOCommitImportOperation

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager APIClient:(CDOGithubAPIClient *)APIClient
{
    self = [super initWithContextManager:contextManager];
    if (self)
    {
        self.APIClient = APIClient;
    }
    return self;
}

- (void)performWorkWithPrivateContext:(NSManagedObjectContext *)context
{
    NSLog(@"Executing %@", NSStringFromClass([self class]));

    NSError *error = nil;
    NSArray *commits = [self.APIClient getCommitsForRepo:@"sqkdatakit" error:&error];
    if (error)
    {
        self.operationError = error;
        NSLog(@"%@", error);
        [self completeOperationBySavingContext:context];
        return;
    }

    CDOCommitImporter *importer = [[CDOCommitImporter alloc] initWithManagedObjectContext:context];
    [importer importJSON:commits];

    [self completeOperationBySavingContext:context];
}

- (NSError *)error
{
    return self.operationError;
}

@end

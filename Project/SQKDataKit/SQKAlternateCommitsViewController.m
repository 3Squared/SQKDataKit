//
//  SQKAlternateCommitsViewController.m
//  SQKDataKit
//
//  Created by Sam Oakley on 13/01/2015.
//  Copyright (c) 2015 3Squared. All rights reserved.
//

#import "SQKAlternateCommitsViewController.h"
#import "SQKJSONLoader.h"
#import "SQKCommitCell.h"
#import "OptimisedImportOperation.h"
#import "Commit.h"
#import "SQKCommitDetailViewController.h"
#import <SQKDataKit/SQKContextManager.h>
#import <SQKDataKit/NSManagedObject+SQKAdditions.h>
#import <SQKDataKit/SQKManagedObjectController.h>

@interface SQKAlternateCommitsViewController () <SQKManagedObjectControllerDelegate>
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) SQKContextManager *contextManager;
@property (nonatomic, strong) SQKManagedObjectController *controller;
@property (nonatomic, strong) id json;
@end

@implementation SQKAlternateCommitsViewController

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager
{
    self = [super init];
    if (self)
    {
        self.contextManager = contextManager;
        self.title = @"Alt.";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title
                                                        image:[UIImage imageNamed:@"list"]
                                                          tag:0];
        self.queue = [[NSOperationQueue alloc] init];
        self.json = [SQKJSONLoader loadJSONFileName:@"data_1500"];
        
        NSFetchRequest *request = [Commit sqk_fetchRequest];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];

        self.controller =
        [[SQKManagedObjectController alloc] initWithFetchRequest:request
                                            managedObjectContext:[self.contextManager mainContext]];
        self.controller.delegate = self;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[SQKCommitCell class]
           forCellReuseIdentifier:NSStringFromClass([SQKCommitCell class])];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.controller performFetch:nil];
}

- (void)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    OptimisedImportOperation *importOperation =
    [[OptimisedImportOperation alloc] initWithContextManager:self.contextManager
                                                        data:self.json];
    __weak typeof(self) weakSelf = self;
    [importOperation setCompletionBlock:^{
        [[NSOperationQueue mainQueue]
         addOperationWithBlock:^{ [weakSelf.refreshControl endRefreshing]; }];
    }];
    
    [self.queue addOperation:importOperation];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SQKCommitCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Commit *commit = [self.controller.managedObjects objectAtIndex:indexPath.row];
    SQKCommitDetailViewController *detailVC = [[SQKCommitDetailViewController alloc] initWithCommit:commit];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SQKCommitCell *cell =
    (SQKCommitCell *)[self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SQKCommitCell class])
                                         forIndexPath:indexPath];

    Commit *commit = [self.controller.managedObjects objectAtIndex:indexPath.row];

    cell.authorNameLabel.text = commit.authorName;
    cell.authorEmailLabel.text = commit.authorEmail;
    cell.dateLabel.text = [commit.date description];
    cell.shaLabel.text = commit.sha;
    cell.messageLabel.text = commit.message;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.controller.managedObjects count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Commit *commit = [self.controller.managedObjects objectAtIndex:indexPath.row];
        [commit.managedObjectContext performBlock:^{
            [commit sqk_deleteObject];
            [commit.managedObjectContext save:nil];
        }];
    }
}


#pragma mark - SQKManagedObjectControllerDelegate

-(void)controller:(SQKManagedObjectController *)controller fetchedObjects:(NSIndexSet *)fetchedObjectIndexes error:(NSError **)error
{
    NSLog(@"fetchedObjects");
    [self.tableView reloadData];
}

-(void)controller:(SQKManagedObjectController *)controller didInsertObjects:(NSIndexSet *)insertedObjectIndexes
{
    NSLog(@"didInsertObjects");
    for (Commit *commit in [self.controller.managedObjects objectsAtIndexes:insertedObjectIndexes]) {
        NSLog(@"Inserted commit: %@", commit.sha);
    }
    [self.controller performFetch:nil];
    [self.tableView reloadData];
}

-(void)controller:(SQKManagedObjectController *)controller didDeleteObjects:(NSIndexSet *)deletedObjectIndexes
{
    NSLog(@"didDeleteObjects");
    for (Commit *commit in [self.controller.managedObjects objectsAtIndexes:deletedObjectIndexes]) {
        NSLog(@"Deleted commit: %@", commit);
    }
    [self.controller performFetch:nil];
    [self.tableView reloadData];
}

@end

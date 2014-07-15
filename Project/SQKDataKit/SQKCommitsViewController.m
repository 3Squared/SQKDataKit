//
//  SQKViewController.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKCommitsViewController.h"
#import "SQKContextManager.h"
#import "NSManagedObject+SQKAdditions.h"
#import "Commit.h"
#import "SQKAppDelegate.h"
#import "SQKCommitCell.h"
#import "SQKCommitDetailViewController.h"
#import "OptimisedImportOperation.h"
#import "SQKJSONLoader.h"

@interface SQKCommitsViewController ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) SQKContextManager *contextManager;
@property (nonatomic, strong) id json;
@end

@implementation SQKCommitsViewController

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager
{
    self = [super initWithContext:[contextManager mainContext] style:UITableViewStylePlain];
    if (self)
    {
        self.contextManager = contextManager;
        self.title = @"List";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"list"] tag:0];
        self.queue = [[NSOperationQueue alloc] init];
        self.json = [SQKJSONLoader loadJSONFileName:@"data_1500"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[SQKCommitCell class]
           forCellReuseIdentifier:NSStringFromClass ([SQKCommitCell class])];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector (refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    OptimisedImportOperation *importOperation =
        [[OptimisedImportOperation alloc] initWithContextManager:self.contextManager data:self.json];
    __weak typeof(self) weakSelf = self;
    [importOperation setCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakSelf.refreshControl endRefreshing];
        }];
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
    Commit *commit = [[self activeFetchedResultsController] objectAtIndexPath:indexPath];
    SQKCommitDetailViewController *detailVC = [[SQKCommitDetailViewController alloc] initWithCommit:commit];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass ([SQKCommitCell class])
                                                                 forIndexPath:indexPath];
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView]
                     configureCell:cell
                       atIndexPath:indexPath];
    return cell;
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
        Commit *commit = [[self activeFetchedResultsController] objectAtIndexPath:indexPath];
        [commit sqk_deleteObject];
    }
}

#pragma mark -

- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString
{
    NSFetchRequest *request = [Commit sqk_fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];

    NSPredicate *filterPredicate = nil;
    if (searchString.length)
    {
        filterPredicate = [NSPredicate predicateWithFormat:@"authorName CONTAINS[cd] %@", searchString];
    }

    [request setPredicate:filterPredicate];

    return request;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                   configureCell:(UITableViewCell *)theCell
                     atIndexPath:(NSIndexPath *)indexPath
{
    SQKCommitCell *cell = (SQKCommitCell *)theCell;
    Commit *commit = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.authorNameLabel.text = commit.authorName;
    cell.authorEmailLabel.text = commit.authorEmail;
    cell.dateLabel.text = [commit.date description];
    cell.shaLabel.text = commit.sha;
    cell.messageLabel.text = commit.message;
}

@end

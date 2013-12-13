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
#import "FetchedResultsControllerDataSource.h"
#import "SQKCommitCell.h"

@interface SQKCommitsViewController () <FetchedResultsControllerDataSourceDelegate, UITextFieldDelegate>
@property (nonatomic, strong) FetchedResultsControllerDataSource *fetchedResultsControllerDataSource;
@end

@implementation SQKCommitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupFetchedResultsController];
}


- (void)setupFetchedResultsController {
    self.fetchedResultsControllerDataSource = [[FetchedResultsControllerDataSource alloc] initWithTableView:self.tableView];
    self.fetchedResultsControllerDataSource.fetchedResultsController = [self commitsFetchedResultsController];
    self.fetchedResultsControllerDataSource.delegate = self;
    self.fetchedResultsControllerDataSource.reuseIdentifier = @"Cell";
    [self.tableView registerClass:[SQKCommitCell class] forCellReuseIdentifier:self.fetchedResultsControllerDataSource.reuseIdentifier];
}


- (NSFetchedResultsController *)commitsFetchedResultsController {
    NSManagedObjectContext *mainContext = [[SQKAppDelegate appDelegate].contextManager mainContext];
    NSFetchRequest *request = [Commit SQK_fetchRequest];
    [request setFetchBatchSize:100];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:mainContext
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];
}

#pragma mark Fetched Results Controller Delegate

- (void)configureCell:(id)theCell withObject:(id)object {
    SQKCommitCell *cell = theCell;
    Commit *commit = object;
    cell.authorNameLabel.text = commit.authorName;
    cell.authorEmailLabel.text = commit.authorEmail;
    cell.dateLabel.text = [commit.date description];
    cell.shaLabel.text = commit.sha;
    cell.messageLabel.text = commit.message;
}

- (void)deleteObject:(id)object {
    Commit *commit = object;
    NSString *actionName = [NSString stringWithFormat:NSLocalizedString(@"Delete \"%@\"", @"Delete undo action name"), commit.sha];
    [self.undoManager setActionName:actionName];
    [commit SQK_deleteObject];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return SQKCommitCellHeight;
}

@end

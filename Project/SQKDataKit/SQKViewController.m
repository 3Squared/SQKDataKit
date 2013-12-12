//
//  SQKViewController.m
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKViewController.h"
#import "SQKContextManager.h"
#import "DataImportOperation.h"
#import "NSManagedObject+SQKAdditions.h"
#import "Commit.h"
#import "SQKAppDelegate.h"
#import "FetchedResultsControllerDataSource.h"
#import "SQKCommitCell.h"

@interface SQKViewController () <FetchedResultsControllerDataSourceDelegate, UITextFieldDelegate>
@property (nonatomic, strong) FetchedResultsControllerDataSource *fetchedResultsControllerDataSource;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation SQKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupFetchedResultsController];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Insert / Update"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(insertUpdate)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete All"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(deleteAll)];
    self.queue = [[NSOperationQueue alloc] init];
}

- (void)insertUpdate {
    id json = [self loadJSON];
    json = [json subarrayWithRange:NSMakeRange(0, 1000)];
    
    NSManagedObjectContext *privateContext = [[[SQKAppDelegate appDelegate] contextManager] newPrivateContext];
    
    DataImportOperation *importOperation = [[DataImportOperation alloc] initWithPrivateContext:privateContext json:json];
    [importOperation setCompletionBlock:^{
        [privateContext save:nil];
    }];
    
    [self.queue addOperation:importOperation];
}

- (void)deleteAll {
    NSBlockOperation *deleteOperation = [NSBlockOperation blockOperationWithBlock:^{
      NSManagedObjectContext *privateContext = [[[SQKAppDelegate appDelegate] contextManager] newPrivateContext];
        [Commit SQK_deleteAllObjectsInContext:privateContext error:nil];
        [privateContext save:nil];
    }];
    [deleteOperation setCompletionBlock:^{
        NSLog(@"Delete all finished");
    }];
    
    [self.queue addOperation:deleteOperation];
}

- (id)loadJSON {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data_large" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    return [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:nil];
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

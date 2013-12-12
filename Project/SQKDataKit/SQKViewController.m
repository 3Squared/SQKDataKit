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

@interface SQKViewController () <FetchedResultsControllerDataSourceDelegate, UITextFieldDelegate>
@property (nonatomic, strong) FetchedResultsControllerDataSource *fetchedResultsControllerDataSource;
@end

@implementation SQKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupFetchedResultsController];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Insert / Update"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(import)];
}

- (void)import {
    id json = [self loadJSON];
    
    NSManagedObjectContext *privateContext = [[[SQKAppDelegate appDelegate] contextManager] newPrivateContext];
    
    DataImportOperation *importOperation = [[DataImportOperation alloc] initWithPrivateContext:privateContext json:json];
    [importOperation setCompletionBlock:^{
        [privateContext save:nil];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        }];
        
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:importOperation];
}

- (id)loadJSON {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data_small" ofType:@"json"];
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.fetchedResultsControllerDataSource.reuseIdentifier];
}


- (NSFetchedResultsController *)commitsFetchedResultsController {
    NSManagedObjectContext *mainContext = [[SQKAppDelegate appDelegate].contextManager mainContext];
    NSFetchRequest *request = [Commit SQK_fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sha" ascending:YES]];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:mainContext
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];
}

#pragma mark Fetched Results Controller Delegate

- (void)configureCell:(id)theCell withObject:(id)object {
    UITableViewCell *cell = theCell;
    Commit *commit = object;
    cell.textLabel.text = commit.sha;
}

- (void)deleteObject:(id)object {
    Commit *commit = object;
    NSString *actionName = [NSString stringWithFormat:NSLocalizedString(@"Delete \"%@\"", @"Delete undo action name"), commit.sha];
    [self.undoManager setActionName:actionName];
    [commit SQK_deleteObject];
}



@end

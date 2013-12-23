//
//  SQKMetricsViewController.m
//  SQKDataKit
//
//  Created by Luke Stringer on 12/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKMetricsViewController.h"
#import "SQKAppDelegate.h"
#import "SQKContextManager.h"
#import "OptimisedImportOperation.h"
#import "NaiveImportOperation.h"
#import "Commit.h"
#import "NSManagedObject+SQKAdditions.h"
#import "SQKContextManager.h"

typedef NS_ENUM(NSInteger, MetricsSection) {
    MetricsSectionNaive,
    MetricsSectionOptimised,
    MetricsSectionDelete,
    MetricsSectionCount
};

typedef NS_ENUM(NSInteger, MetricsRow) {
    MetricsRowStart,
    MetricsRowInformation,
    MetricsRowCount
};

@interface SQKMetricsViewController ()
@property (nonatomic, assign) BOOL isNaiveImporting;
@property (nonatomic, assign) BOOL isOptimisedImporting;
@property (nonatomic, assign) BOOL isDeleting;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) id json;
@property (nonatomic, assign) NSTimeInterval naiveImportDuration;
@property (nonatomic, assign) NSTimeInterval optimisedImportDuration;
@end

static NSString *CellIdentifier = @"Cell";

@implementation SQKMetricsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.queue = [[NSOperationQueue alloc] init];
    self.json = [[self loadJSON] subarrayWithRange:NSMakeRange(0, 5000)];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MetricsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case MetricsSectionNaive:
            return MetricsRowCount;
            break;
        case MetricsSectionOptimised:
            return MetricsRowCount;
            break;
        case MetricsSectionDelete:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == MetricsSectionDelete) {
        [self configureDeleteCell:cell];
    }
    
    else if (indexPath.row == MetricsRowStart) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if ((indexPath.section == MetricsSectionNaive && self.isNaiveImporting) || (indexPath.section == MetricsSectionOptimised && self.isOptimisedImporting)) {
            cell.textLabel.text = @"Importing...";
            [activityView startAnimating];
        }
        else {
            cell.textLabel.text = @"Start";
            [activityView stopAnimating];
        }
        cell.accessoryView = activityView;
    }
    
    else if (indexPath.row == MetricsRowInformation) {
        switch (indexPath.section) {
            case MetricsSectionNaive:
                cell.textLabel.text = [NSString stringWithFormat:@"Import Duration: %0.2f seconds", self.naiveImportDuration];
                break;
            case MetricsSectionOptimised:
                cell.textLabel.text = [NSString stringWithFormat:@"Import Duration: %0.2f seconds", self.optimisedImportDuration];
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void)configureDeleteCell:(UITableViewCell *)cell {
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if (self.isDeleting) {
        [activityView startAnimating];
        cell.textLabel.text = @"Deleting...";
    }
    else {
        
        cell.textLabel.text = @"Delete All";
        [activityView stopAnimating];
    }
    cell.accessoryView = activityView;
}

- (void)configureStartCell:(UITableViewCell *)cell {
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case MetricsSectionNaive:
            return @"Naive Import";
            break;
        case MetricsSectionOptimised:
            return @"Optimised Import";
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == MetricsRowStart && indexPath.section == MetricsSectionNaive && !self.isOptimisedImporting && !self.isNaiveImporting) {
        [self insertOrUpdateWithNaiveOperation];
        self.isNaiveImporting = YES;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    else if (indexPath.row == MetricsRowStart && indexPath.section == MetricsSectionOptimised && !self.isNaiveImporting && !self.isOptimisedImporting) {
        [self insertOrUpdateWithOptimisedOperation];
        self.isOptimisedImporting = YES;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    else if (indexPath.section == MetricsSectionDelete) {
        if (!self.isNaiveImporting && !self.isOptimisedImporting) {
            self.isDeleting = YES;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:MetricsSectionDelete]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self deleteAll];
        }
        [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:MetricsSectionDelete] animated:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Data manipulation

- (void)insertOrUpdateWithNaiveOperation {
    NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
    
    NaiveImportOperation *importOperation = [[NaiveImportOperation alloc] initWithPrivateContext:privateContext json:self.json];
    __weak typeof(NaiveImportOperation) *weakOperation = importOperation;
    [importOperation setCompletionBlock:^{
        [privateContext save:nil];
        
        __strong typeof(NaiveImportOperation) *strongOperation = weakOperation;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.isNaiveImporting = NO;
            self.naiveImportDuration = [[NSDate date] timeIntervalSinceDate:strongOperation.startDate];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:MetricsSectionNaive] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }];
    
    [self.queue addOperation:importOperation];
}

- (void)insertOrUpdateWithOptimisedOperation {
    NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
    
    OptimisedImportOperation *importOperation = [[OptimisedImportOperation alloc] initWithPrivateContext:privateContext json:self.json];
    __weak typeof(OptimisedImportOperation) *weakOperation = importOperation;
    [importOperation setCompletionBlock:^{
        [privateContext save:nil];
        
        __strong typeof(OptimisedImportOperation) *strongOperation = weakOperation;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.isOptimisedImporting = NO;
            self.optimisedImportDuration = [[NSDate date] timeIntervalSinceDate:strongOperation.startDate];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:MetricsSectionOptimised] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }];
    
    [self.queue addOperation:importOperation];
}

- (void)deleteAll {
    NSBlockOperation *deleteOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
        [Commit SQK_deleteAllObjectsInContext:privateContext error:nil];
        [privateContext save:nil];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.isDeleting = NO;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:MetricsSectionDelete]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
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

@end

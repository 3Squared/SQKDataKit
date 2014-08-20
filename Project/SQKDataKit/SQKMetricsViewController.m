//
//  SQKMetricsViewController.m
//  SQKDataKit
//
//  Created by Luke Stringer on 12/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKMetricsViewController.h"
#import "SQKAppDelegate.h"
#import "OptimisedImportOperation.h"
#import "NaiveImportOperation.h"
#import "Commit.h"
#import "SQKJSONLoader.h"

#import <SQKDataKit/SQKContextManager.h>
#import <SQKDataKit/NSManagedObject+SQKAdditions.h>
#import <SQKDataKit/NSManagedObjectContext+SQKAdditions.h>

typedef NS_ENUM(NSInteger, MetricsSection)
{ MetricsSectionNaive,
  MetricsSectionOptimised,
  MetricsSectionDeleteAll,
  MetricsSectionCount };

typedef NS_ENUM(NSInteger, MetricsRow)
{ MetricsRowStart,
  MetricsRowInformation,
  MetricsRowCount };

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

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.queue = [[NSOperationQueue alloc] init];
        self.json = [SQKJSONLoader loadJSONFileName:@"data_1500"];
        self.title = @"Metrics";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title
                                                        image:[UIImage imageNamed:@"metrics"]
                                                          tag:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MetricsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case MetricsSectionNaive:
            return MetricsRowCount;
            break;
        case MetricsSectionOptimised:
            return MetricsRowCount;
            break;
        case MetricsSectionDeleteAll:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (indexPath.section == MetricsSectionDeleteAll)
    {
        [self configureDeleteCell:cell];
    }
    else if (indexPath.row == MetricsRowStart)
    {
        [self configureStartCell:cell inSection:indexPath.section];
    }
    else if (indexPath.row == MetricsRowInformation)
    {
        [self configureInformationCell:cell inSection:indexPath.section];
    }

    return cell;
}

- (void)configureDeleteCell:(UITableViewCell *)cell
{
    UIActivityIndicatorView *activityView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if (self.isDeleting)
    {
        [activityView startAnimating];
        cell.textLabel.text = @"Deleting...";
    }
    else
    {
        cell.textLabel.text = @"Delete All";
        [activityView stopAnimating];
    }
    cell.accessoryView = activityView;
}

- (void)configureStartCell:(UITableViewCell *)cell inSection:(MetricsSection)section
{
    UIActivityIndicatorView *activityView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if ((section == MetricsSectionNaive && self.isNaiveImporting)
        || (section == MetricsSectionOptimised && self.isOptimisedImporting))
    {
        cell.textLabel.text = @"Importing...";
        [activityView startAnimating];
    }
    else
    {
        cell.textLabel.text = @"Start";
        [activityView stopAnimating];
    }
    cell.accessoryView = activityView;
}

- (void)configureInformationCell:(UITableViewCell *)cell inSection:(MetricsSection)section
{
    switch (section)
    {
        case MetricsSectionNaive:
            cell.textLabel.text =
                [NSString stringWithFormat:@"Import Duration: %0.2f seconds", self.naiveImportDuration];
            break;
        case MetricsSectionOptimised:
            cell.textLabel.text =
                [NSString stringWithFormat:@"Import Duration: %0.2f seconds", self.optimisedImportDuration];
            break;
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL indexPathIsStartNaiveImport = indexPath.row == MetricsRowStart && indexPath.section == MetricsSectionNaive;
    BOOL indePathIsStartOptmisedImport = indexPath.row == MetricsRowStart
                                         && indexPath.section == MetricsSectionOptimised;
    BOOL indexPathIsDeleteAll = indexPath.section == MetricsSectionDeleteAll;
    BOOL notImporting = !self.isOptimisedImporting && !self.isNaiveImporting;

    if (indexPathIsStartNaiveImport && notImporting && !self.isDeleting)
    {
        [self insertOrUpdateWithNaiveOperation];
        self.isNaiveImporting = YES;
        self.naiveImportDuration = 0.0f;
    }

    else if (indePathIsStartOptmisedImport && notImporting && !self.isDeleting)
    {
        [self insertOrUpdateWithOptimisedOperation];
        self.isOptimisedImporting = YES;
        self.optimisedImportDuration = 0.0f;
    }

    else if (indexPathIsDeleteAll && notImporting && !self.isDeleting)
    {
        self.isDeleting = YES;
        [self deleteAll];
    }

    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]
             withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Data import

- (void)insertOrUpdateWithNaiveOperation
{
    NaiveImportOperation *importOperation =
        [[NaiveImportOperation alloc] initWithContextManager:self.contextManager data:self.json];
    __weak typeof(NaiveImportOperation) *weakOperation = importOperation;
    [importOperation setCompletionBlock:^{

        __strong typeof(NaiveImportOperation) *strongOperation = weakOperation;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.isNaiveImporting = NO;
            self.naiveImportDuration = [[NSDate date] timeIntervalSinceDate:strongOperation.startDate];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:MetricsSectionNaive]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }];

    [self.queue addOperation:importOperation];
}

- (void)insertOrUpdateWithOptimisedOperation
{
    OptimisedImportOperation *importOperation =
        [[OptimisedImportOperation alloc] initWithContextManager:self.contextManager
                                                            data:self.json];
    __weak typeof(OptimisedImportOperation) *weakOperation = importOperation;
    [importOperation setCompletionBlock:^{

        __strong typeof(OptimisedImportOperation) *strongOperation = weakOperation;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.isOptimisedImporting = NO;
            self.optimisedImportDuration = [[NSDate date] timeIntervalSinceDate:strongOperation.startDate];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:MetricsSectionOptimised]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }];

    [self.queue addOperation:importOperation];
}

#pragma mark - Data delete

- (void)deleteAll
{
    NSBlockOperation *deleteOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *privateContext = [self.contextManager newPrivateContext];
        privateContext.shouldMergeOnSave = YES;
        [Commit sqk_deleteAllObjectsInContext:privateContext error:nil];
        [privateContext save:nil];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.isDeleting = NO;
            [self.tableView
                reloadRowsAtIndexPaths:
                    @[[NSIndexPath indexPathForRow:0 inSection:MetricsSectionDeleteAll]]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }];

    [self.queue addOperation:deleteOperation];
}


@end

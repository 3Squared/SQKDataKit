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

typedef NS_ENUM(NSInteger, MetricsSection) {
    MetricsSectionNaive,
    MetricsSectionOptimised,
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
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) id json;
@end

static NSString *CellIdentifier = @"Cell";

@implementation SQKMetricsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.queue = [[NSOperationQueue alloc] init];
    self.json = [self loadJSON];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MetricsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MetricsRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case MetricsRowStart: {
            cell.textLabel.text = @"Start";
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            if ((indexPath.section == MetricsSectionNaive && self.isNaiveImporting) || (indexPath.section == MetricsSectionOptimised && self.isOptimisedImporting)) {
                [activityView startAnimating];
            }
            else {
                [activityView stopAnimating];
            }
            cell.accessoryView = activityView;
        }
            break;
            
        case MetricsRowInformation: {
            cell.textLabel.text = @"Info";
        }
            break;
            
        default:
            break;
    }
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == MetricsRowStart && indexPath.section == MetricsSectionNaive && !self.isOptimisedImporting && !self.isNaiveImporting) {
        [self insertOrUpdateWithNaiveOperation];
        self.isNaiveImporting = YES;
    }
    
    if (indexPath.row == MetricsRowStart && indexPath.section == MetricsSectionOptimised && !self.isNaiveImporting && !self.isOptimisedImporting) {
        [self insertOrUpdateWithOptimisedOperation];
        self.isOptimisedImporting = YES;
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertOrUpdateWithNaiveOperation {
    NSManagedObjectContext *privateContext = [[[SQKAppDelegate appDelegate] contextManager] newPrivateContext];
    
    NaiveImportOperation *importOperation = [[NaiveImportOperation alloc] initWithPrivateContext:privateContext json:self.json];
    [importOperation setCompletionBlock:^{
        [privateContext save:nil];
        NSLog(@"Done saving");
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.isNaiveImporting = NO;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:MetricsRowStart inSection:MetricsSectionNaive]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        
        
    }];
    
    [self.queue addOperation:importOperation];
}

- (void)insertOrUpdateWithOptimisedOperation {
    NSManagedObjectContext *privateContext = [[[SQKAppDelegate appDelegate] contextManager] newPrivateContext];
    
    OptimisedImportOperation *importOperation = [[OptimisedImportOperation alloc] initWithPrivateContext:privateContext json:self.json];
    [importOperation setCompletionBlock:^{
        [privateContext save:nil];
        NSLog(@"Done saving");
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.isOptimisedImporting = NO;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:MetricsRowStart inSection:MetricsSectionOptimised]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        
    }];
    
    [self.queue addOperation:importOperation];
}


- (id)loadJSON {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data_large" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:kNilOptions
                                             error:nil];
}

@end

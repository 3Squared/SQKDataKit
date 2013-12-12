//
//  SQKMetricsViewController.m
//  SQKDataKit
//
//  Created by Luke Stringer on 12/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKMetricsViewController.h"

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
@end

static NSString *CellIdentifier = @"Cell";

@implementation SQKMetricsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
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
    self.isNaiveImporting = (indexPath.row == MetricsRowStart && indexPath.section == MetricsSectionNaive);
    self.isOptimisedImporting = (indexPath.row == MetricsRowStart && indexPath.section == MetricsSectionOptimised);
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end

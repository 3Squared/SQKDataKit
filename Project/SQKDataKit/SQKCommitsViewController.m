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

@interface SQKCommitsViewController () <NSFetchedResultsControllerDelegate>
@end

@implementation SQKCommitsViewController

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    self = [super initWithContext:context style:UITableViewStylePlain];
    if (self) {
		self.title = @"List";
		self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"list"] tag:0];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    [self.tableView registerClass:[SQKCommitCell class] forCellReuseIdentifier:NSStringFromClass([SQKCommitCell class])];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SQKCommitCellHeight;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SQKCommitCell class]) forIndexPath:indexPath];
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];
	return cell;
}

#pragma mark -

-(NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString {
    NSFetchRequest *request = [Commit SQK_fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];

    NSPredicate* filterPredicate = nil;
    if(searchString.length)
    {
        filterPredicate = [NSPredicate predicateWithFormat:@"authorName CONTAINS[cd] %@", searchString];
    }
    
    [request setPredicate:filterPredicate];
    
    return request;
}

-(void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)indexPath {
    SQKCommitCell *cell = (SQKCommitCell*)theCell;
    Commit *commit = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.authorNameLabel.text = commit.authorName;
    cell.authorEmailLabel.text = commit.authorEmail;
    cell.dateLabel.text = [commit.date description];
    cell.shaLabel.text = commit.sha;
    cell.messageLabel.text = commit.message;
}

@end

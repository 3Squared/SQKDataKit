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
@property (nonatomic, strong, readwrite) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation SQKCommitsViewController

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
		self.context = context;
		self.title = @"List";
		self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"list"] tag:0];
		[self.tableView registerClass:[SQKCommitCell class] forCellReuseIdentifier:NSStringFromClass([SQKCommitCell class])];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupFetchedResultsController];
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [Commit SQK_fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																		managedObjectContext:self.context
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
	self.fetchedResultsController.delegate = self;
	[self.fetchedResultsController performFetch:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return SQKCommitCellHeight;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    SQKCommitCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SQKCommitCell class]) forIndexPath:indexPath];
    [self configureCell:cell withObject:object];
	return cell;
}


#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller {
	/**
	 *  Call back here could be on a non-main thread.
	 */
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		[self.tableView beginUpdates];
	}];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
	/**
	 *  Call back here could be on a non-main thread.
	 */
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
			[self.tableView endUpdates];
	}];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath {
	/**
	 *  Call back here could be on a non-main thread.
	 */
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		switch(type){
			case NSFetchedResultsChangeInsert:
				[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
				break;
				
			case NSFetchedResultsChangeDelete:
				[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
				break;
				
			case NSFetchedResultsChangeUpdate: {
				id cell = [self.tableView cellForRowAtIndexPath:indexPath];
				[self configureCell:cell withObject:anObject];
			}
				break;
				
			case NSFetchedResultsChangeMove:
				[self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
				break;
		}
	}];
	
    
}

#pragma mark - Cell config

- (void)configureCell:(SQKCommitCell *)theCell withObject:(id)object {
    SQKCommitCell *cell = theCell;
    Commit *commit = object;
    cell.authorNameLabel.text = commit.authorName;
    cell.authorEmailLabel.text = commit.authorEmail;
    cell.dateLabel.text = [commit.date description];
    cell.shaLabel.text = commit.sha;
    cell.messageLabel.text = commit.message;
}


@end

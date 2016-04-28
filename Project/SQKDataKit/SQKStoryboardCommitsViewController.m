//
//  SQKStoryboardCommitsViewController.m
//  SQKDataKit
//
//  Created by Sam Oakley on 28/04/2016.
//  Copyright © 2016 3Squared. All rights reserved.
//

#import "Commit.h"
#import "SQKAppDelegate.h"
#import "SQKStoryboardCommitsViewController.h"
#import <SQKDataKit/NSManagedObject+SQKAdditions.h>
#import <SQKDataKit/SQKContextManager.h>

@interface SQKStoryboardCommitsViewController ()

@end

@implementation SQKStoryboardCommitsViewController

- (NSManagedObjectContext *)managedObjectContext
{
    return [((SQKAppDelegate *)[[UIApplication sharedApplication] delegate]).contextManager mainContext];
}

#pragma mark -

- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString
{
    NSFetchRequest *request = [Commit sqk_fetchRequest];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ];

    NSPredicate *filterPredicate = nil;
    if (searchString.length)
    {
        filterPredicate = [NSPredicate predicateWithFormat:@"authorName CONTAINS[cd] %@", searchString];
    }

    [request setPredicate:filterPredicate];

    return request;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                   configureCell:(UITableViewCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath
{
    Commit *commit = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = commit.message;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self fetchedResultsController:[self activeFetchedResultsController] configureCell:cell atIndexPath:indexPath];
    return cell;
}

@end

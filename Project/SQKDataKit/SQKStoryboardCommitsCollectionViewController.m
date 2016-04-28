//
//  SQKStoryboardCommitsCollectionViewController.m
//  SQKDataKit
//
//  Created by Sam Oakley on 28/04/2016.
//  Copyright © 2016 3Squared. All rights reserved.
//

#import "Commit.h"
#import "SQKAppDelegate.h"
#import "SQKStoryboardCollectionHeaderView.h"
#import "SQKStoryboardCollectionViewCell.h"
#import "SQKStoryboardCommitsCollectionViewController.h"
#import <SQKDataKit/NSManagedObject+SQKAdditions.h>
#import <SQKDataKit/SQKContextManager.h>
#import <SQKDataKit/SQKFetchedCollectionViewController.h>

@interface SQKStoryboardCommitsCollectionViewController ()

@end

@implementation SQKStoryboardCommitsCollectionViewController

#pragma mark -

- (NSManagedObjectContext *)managedObjectContext
{
    return [((SQKAppDelegate *)[[UIApplication sharedApplication] delegate]).contextManager mainContext];
}

- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString
{
    NSFetchRequest *request = [Commit sqk_fetchRequest];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"authorName" ascending:YES] ];

    NSPredicate *filterPredicate = nil;
    if (searchString.length)
    {
        filterPredicate = [NSPredicate predicateWithFormat:@"authorName CONTAINS[cd] %@", searchString];
    }

    [request setPredicate:filterPredicate];

    return request;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureItemCell:(UICollectionViewCell *)theItemCell atIndexPath:(NSIndexPath *)indexPath
{
    Commit *commit = [fetchedResultsController objectAtIndexPath:indexPath];
    SQKStoryboardCollectionViewCell *cell = (SQKStoryboardCollectionViewCell *)theItemCell;
    cell.textLabel.text = [[self firstCharactersForString:commit.authorName] uppercaseString];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    return itemCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self fetchedResultsController:self.fetchedResultsController
                 configureItemCell:cell
                       atIndexPath:indexPath];
}

- (NSString *)sectionKeyPathForSearchableFetchedResultsController:(SQKFetchedCollectionViewController *)controller
{
    return @"authorName";
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 26, 10, 26);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader)
    {
        SQKStoryboardCollectionHeaderView *view = (SQKStoryboardCollectionHeaderView *)[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
        id<NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[indexPath.section];
        view.textLabel.text = [section name];
        return view;
    }
    return nil;
}

- (NSString *)firstCharactersForString:(NSString *)string
{
    NSMutableString *firstCharacters = [NSMutableString string];

    NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    [words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
      NSString *firstLetter = [word substringToIndex:1];
      [firstCharacters appendString:firstLetter];
    }];

    return firstCharacters;
}

@end

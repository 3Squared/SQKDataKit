//
//  SQKCommitsCollectionViewController.m
//  SQKDataKit
//
//  Created by Ste Prescott on 07/01/2015.
//  Copyright (c) 2015 3Squared. All rights reserved.
//

#import "SQKCommitsCollectionViewController.h"
#import "Commit.h"
#import "SQKCommitItemCell.h"
#import "SQKCommitDetailViewController.h"
#import "SQKAppDelegate.h"
#import "OptimisedImportOperation.h"
#import "SQKJSONLoader.h"

#import <SQKDataKit/SQKContextManager.h>
#import <SQKDataKit/NSManagedObject+SQKAdditions.h>

@interface SQKCommitsCollectionViewController ()
@end

@implementation SQKCommitsCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout contextManager:(SQKContextManager *)contextManager
{
    self = [super initWithCollectionViewLayout:layout context:[contextManager mainContext]];
    
    if (self)
    {
        [self.collectionView registerClass:[SQKCommitItemCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        
        self.contextManager = contextManager;
        self.title = @"Collection";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title
                                                        image:[UIImage imageNamed:@"collection"]
                                                          tag:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.5;
    longPressGesture.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:longPressGesture];
}

#pragma mark -

- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *request = [Commit sqk_fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    return request;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureItemCell:(UICollectionViewCell *)theItemCell atIndexPath:(NSIndexPath *)indexPath
{
    SQKCommitItemCell *itemCell = (SQKCommitItemCell *)theItemCell;
//    Commit *commit = [fetchedResultsController objectAtIndexPath:indexPath];
//    itemCell.authorNameLabel.text = [[self firstCharactersForString:commit.authorName] uppercaseString];
//    itemCell.dateLabel.text = [commit.date description];
    itemCell.authorNameLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    itemCell.dateLabel.text = [NSString stringWithFormat:@"Section %ld row %ld", (long)indexPath.section, (long)indexPath.row];
    itemCell.isEditing = self.editing;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SQKCommitItemCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    return itemCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self fetchedResultsController:self.fetchedResultsController
                 configureItemCell:cell
                       atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Commit *commit = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    if(self.editing)
    {
        [commit sqk_deleteObject];
    }
    else
    {
        Commit *commit = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        SQKCommitDetailViewController *detailVC = [[SQKCommitDetailViewController alloc] initWithCommit:commit];
        [self showViewController:detailVC sender:self];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 26, 10, 26); // top, left, bottom, right
}

- (NSString *)firstCharactersForString:(NSString *)string
{
    NSMutableString *firstCharacters = [NSMutableString string];
    
    NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
        NSString * firstLetter = [word substringToIndex:1];
        [firstCharacters appendString:firstLetter];
    }];
    
    return firstCharacters;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        [self toggleEditing];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.collectionView reloadData];
}

- (void)toggleEditing
{
    if(self.editing)
    {
        self.editing = NO;
    }
    else
    {
        self.editing = YES;
    }
}

@end

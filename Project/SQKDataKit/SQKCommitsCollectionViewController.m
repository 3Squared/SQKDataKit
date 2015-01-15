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
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) id json;
@end

@implementation SQKCommitsCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout contextManager:(SQKContextManager *)contextManager
{
    self = [super initWithCollectionViewLayout:layout context:[contextManager mainContext]];

    if (self)
    {
        self.queue = [[NSOperationQueue alloc] init];
        self.json = [SQKJSONLoader loadJSONFileName:@"data_1500"];

        [self.collectionView registerClass:[SQKCommitItemCell class] forCellWithReuseIdentifier:@"cellIdentifier"];

        self.contextManager = contextManager;
        self.title = @"Collection";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title
                                                        image:[UIImage imageNamed:@"collection"]
                                                          tag:0];

        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"dd/MM/yy at hh:mm";
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

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    OptimisedImportOperation *importOperation = [[OptimisedImportOperation alloc] initWithContextManager:self.contextManager
                                                                                                    data:self.json];
    __weak typeof(self) weakSelf = self;
    [importOperation setCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakSelf.refreshControl endRefreshing];
        }];
    }];

    [self.queue addOperation:importOperation];
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

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureItemCell:(UICollectionViewCell *)theItemCell atIndexPath:(NSIndexPath *)indexPath
{
    SQKCommitItemCell *itemCell = (SQKCommitItemCell *)theItemCell;
    Commit *commit = [fetchedResultsController objectAtIndexPath:indexPath];
    itemCell.authorNameLabel.text = [[self firstCharactersForString:commit.authorName] uppercaseString];
    itemCell.dateLabel.text = [self.dateFormatter stringFromDate:commit.date];
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

    if (self.editing)
    {
        [commit sqk_deleteObject];
        [commit.managedObjectContext save:nil];
    }
    else
    {
        Commit *commit = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        SQKCommitDetailViewController *detailVC = [[SQKCommitDetailViewController alloc] initWithCommit:commit];
        [self showViewController:detailVC sender:self];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(self.searchingEnabled ? 54 : 10, 26, 10, 26);
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

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
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
    if (self.editing)
    {
        self.editing = NO;
    }
    else
    {
        self.editing = YES;
    }
}

@end

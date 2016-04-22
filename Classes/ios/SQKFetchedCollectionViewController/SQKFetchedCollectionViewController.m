//
//  SQKFetchedCollectionViewController.m
//  Pods
//
//  Created by Ste Prescott on 07/01/2015.
//
//

#import "SQKFetchedCollectionViewController.h"

#define mustOverride()                                                                                                            \
    @throw [NSException exceptionWithName:NSInvalidArgumentException                                                              \
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass", __PRETTY_FUNCTION__] \
                                 userInfo:nil]

@interface SQKFetchedCollectionViewController ()

@property (strong, nonatomic, readwrite) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic, readwrite) UISearchBar *searchBar;
@property (nonatomic, assign, readwrite) BOOL searchIsActive;

@property (strong, nonatomic) NSMutableArray *sectionChanges;
@property (strong, nonatomic) NSMutableArray *itemChanges;

@end

@implementation SQKFetchedCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout context:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self)
    {
        self.managedObjectContext = context;
        self.searchingEnabled = YES;
        self.layout = layout;
    }

    return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout context:(NSManagedObjectContext *)context searchingEnabled:(BOOL)searchingEnabled
{
    self = [super init];

    if (self)
    {
        self.managedObjectContext = context;
        self.searchingEnabled = searchingEnabled;
        self.layout = layout;
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];

    if (self)
    {
        self.searchingEnabled = YES;

        self.layout = [[UICollectionViewFlowLayout alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.collectionViewLayout = self.layout;

    if (self.searchingEnabled)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;

        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -44, CGRectGetWidth(self.collectionView.frame), 44)];
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchBar.delegate = self;
        [self.collectionView addSubview:self.searchBar];
    }

    self.fetchedResultsController = [self fetchedResultsControllerWithSearch:nil];

    if (self.refreshControl)
    {
        [self setRefreshControl:self.refreshControl];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.searchingEnabled)
    {
        if (self.searchIsActive)
        {
            [self.searchBar becomeFirstResponder];
        }
        else
        {
            [self.collectionView setContentInset:UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0)];
            [self.collectionView setContentOffset:CGPointMake(0, 0)];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.editing = NO;
}

- (void)didReceiveMemoryWarning
{
    _fetchedResultsController.delegate = nil;
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _fetchedResultsController.delegate = nil;
}

#pragma mark - Refreshing

- (void)setRefreshControl:(UIRefreshControl *)refreshControl
{
    [_refreshControl removeFromSuperview];
    _refreshControl = refreshControl;
    if (_refreshControl && self.collectionView)
    {
        [self.collectionView addSubview:_refreshControl];
        _refreshControl.bounds = CGRectOffset(_refreshControl.bounds, 0, 44);
        [self.collectionView sendSubviewToBack:_refreshControl];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = [[[self fetchedResultsController] sections] count];
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItems = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsController];
    NSArray *sections = fetchController.sections;

    if (sections.count > 0)
    {
        id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfItems = [sectionInfo numberOfObjects];
    }

    return numberOfItems;
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue
{
    __block BOOL shouldReload = NO;
    [self.itemChanges enumerateObjectsUsingBlock:^(NSDictionary *change, NSUInteger idx, BOOL *stop) {
      [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
        NSIndexPath *indexPath = obj;

        switch (type)
        {
            case NSFetchedResultsChangeInsert:
            {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0)
                {
                    shouldReload = YES;
                }
                else
                {
                    shouldReload = NO;
                }
                break;
            }

            case NSFetchedResultsChangeDelete:
            {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1)
                {
                    shouldReload = YES;
                }
                else
                {
                    shouldReload = NO;
                }
                break;
            }

            case NSFetchedResultsChangeUpdate:
            {
                shouldReload = NO;
                break;
            }

            case NSFetchedResultsChangeMove:
            {
                shouldReload = NO;
                break;
            }
        }
      }];

    }];

    return shouldReload;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    mustOverride();
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
               configureItemCell:(UICollectionViewCell *)theItemCell
                     atIndexPath:(NSIndexPath *)indexPath
{
    mustOverride();
}

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.sectionChanges = [NSMutableArray array];
    self.itemChanges = [NSMutableArray array];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            change[@(type)] = newIndexPath;
            break;
        }

        case NSFetchedResultsChangeDelete:
        {
            change[@(type)] = indexPath;
            break;
        }

        case NSFetchedResultsChangeUpdate:
        {
            change[@(type)] = indexPath;
            break;
        }

        case NSFetchedResultsChangeMove:
        {
            change[@(type)] = @[ indexPath, newIndexPath ];
            break;
        }
    }

    [_itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil)
    {
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)]];
    }
    else
    {
        [self.collectionView performBatchUpdates:^{

          //Deal with the sections
          [self.sectionChanges enumerateObjectsUsingBlock:^(NSDictionary *change, NSUInteger idx, BOOL *stop) {

            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

              NSFetchedResultsChangeType type = [key integerValue];

              switch (type)
              {
                  case NSFetchedResultsChangeInsert:
                  {
                      [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                      break;
                  }
                  case NSFetchedResultsChangeUpdate:
                  {
                      [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                      break;
                  }
                  case NSFetchedResultsChangeMove:
                  {
                      NSArray *moves = change[key];
                      [moves enumerateObjectsUsingBlock:^(NSArray *move, NSUInteger idx, BOOL *stop) {
                        [self.collectionView moveSection:[move[0] integerValue] toSection:[move[1] integerValue]];
                      }];
                      break;
                  }
                  case NSFetchedResultsChangeDelete:
                  {
                      [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                      break;
                  }
              }
            }];
          }];

          //Now deal with the items
          [self.itemChanges enumerateObjectsUsingBlock:^(NSDictionary *change, NSUInteger idx, BOOL *stop) {

            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

              NSFetchedResultsChangeType type = [key unsignedIntegerValue];

              switch (type)
              {
                  case NSFetchedResultsChangeInsert:
                  {
                      [self.collectionView insertItemsAtIndexPaths:@[ obj ]];
                      break;
                  }
                  case NSFetchedResultsChangeDelete:
                  {
                      [self.collectionView deleteItemsAtIndexPaths:@[ obj ]];
                      break;
                  }
                  case NSFetchedResultsChangeUpdate:
                  {
                      [self fetchedResultsController:self.fetchedResultsController
                                   configureItemCell:[self.collectionView cellForItemAtIndexPath:obj]
                                         atIndexPath:obj];
                      break;
                  }
                  case NSFetchedResultsChangeMove:
                  {
                      [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                      break;
                  }
              }
            }];
          }];

        }
            completion:^(BOOL finished) {
              self.sectionChanges = nil;
              self.itemChanges = nil;
            }];
    }
}

#pragma mark - FetchedResultsController

- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString
{
    mustOverride();
}

- (NSString *)sectionKeyPathForSearchableFetchedResultsController:(SQKFetchedCollectionViewController *)controller
{
    return nil;
}

- (NSFetchedResultsController *)fetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSString *sectionKeyPath;

    if (!self.searchIsActive || self.showsSectionsWhenSearching)
    {
        sectionKeyPath = [self sectionKeyPathForSearchableFetchedResultsController:self];
    }

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequestForSearch:searchString]
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:sectionKeyPath
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return self.fetchedResultsController;
}

- (void)reloadFetchedResultsControllerForSearch:(NSString *)search
{
    self.fetchedResultsController = [self fetchedResultsControllerWithSearch:search];
}

- (void)resetSearch
{
    self.searchBar.text = @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

#pragma mark - Search bar

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    /**
     *  Do this scroll enable/disable hack as the searchBar insists on scrolling the collection view when it becomes active.
     *  FUTURE PERSON: PLEASE REPLACE THIS IF YOU KNOW A BETTER WAY.
     */
    self.collectionView.scrollEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      self.collectionView.scrollEnabled = YES;
    });

    self.searchIsActive = YES;

    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:YES animated:YES];

    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.fetchedResultsController = [self fetchedResultsControllerWithSearch:nil];

    self.searchIsActive = NO;
    self.searchBar.text = nil;
    [self fetchedResultsControllerWithSearch:nil];
    [self.collectionView reloadData];

    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self fetchedResultsControllerWithSearch:searchText];
    [self.collectionView reloadData];
    [self.searchBar becomeFirstResponder];
}

@end

//
//  SQKFetchedTableViewController.h
//  Based on SJOSearchableFetchedResultsController.h
//
//  Created by Sam Oakley on 15/07/2013.
//  Copyright (c) 2013 Sam Oakley. All rights reserved.
//

#import "SQKFetchedTableViewController.h"

#define mustOverride()                                                                                            \
    @throw [NSException                                                                                           \
        exceptionWithName:NSInvalidArgumentException                                                              \
                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass", __PRETTY_FUNCTION__] \
                 userInfo:nil]
#define mustSet()                                                                                                   \
    @throw [NSException                                                                                             \
        exceptionWithName:NSInvalidArgumentException                                                                \
                   reason:[NSString                                                                                 \
                              stringWithFormat:@"%s must be set in your subclass init method", __PRETTY_FUNCTION__] \
                 userInfo:nil]

@interface SQKFetchedTableViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, assign, readwrite) BOOL searchIsActive;
@end

@implementation SQKFetchedTableViewController

- (instancetype)initWithContext:(NSManagedObjectContext *)managedObjectContext
                          style:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style])
    {
        self.managedObjectContext = managedObjectContext;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UISearchBar *searchBar = [[UISearchBar alloc] init];
    _searchController =
        [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.frame = CGRectMake(0, 0, 0, 44);
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self activeTableView] reloadData];
    [self showEmptyView:([[[self activeFetchedResultsController] fetchedObjects] count] == 0)];
}

- (void)didReceiveMemoryWarning
{
    _fetchedResultsController.delegate = nil;
    _searchFetchedResultsController.delegate = nil;
    _searchController.delegate = nil;
    _searchController.searchResultsDelegate = nil;
    _searchController.searchResultsDataSource = nil;
    _searchController.searchBar.delegate = nil;
    _searchController = nil;
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _fetchedResultsController.delegate = nil;
    _searchFetchedResultsController.delegate = nil;
    _searchController.delegate = nil;
    _searchController.searchResultsDelegate = nil;
    _searchController.searchResultsDataSource = nil;
    _searchController.searchBar.delegate = nil;
    _searchController = nil;
}

#pragma mark -
#pragma mark Fetched results controller data source

- (UITableView *)activeTableView
{
    return [self activeFetchedResultsController] == self.fetchedResultsController ?
               self.tableView :
               self.searchController.searchResultsTableView;
}

- (NSFetchedResultsController *)activeFetchedResultsController
{
    return (self.searchController && self.searchController.active) ? self.searchFetchedResultsController :
                                                                     self.fetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                   configureCell:(UITableViewCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath
{
    mustOverride();
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    mustOverride();
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    if (sections.count > 0)
    {
        id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }

    return numberOfRows;
}


#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    /**
     *  Callbacks could be on a non-main thread.
     */
    [self.managedObjectContext performBlockAndWait:^{
        UITableView *tableView = controller == self.fetchedResultsController ?
                                     self.tableView :
                                     self.searchController.searchResultsTableView;
        [tableView beginUpdates];
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.managedObjectContext performBlockAndWait:^{
        UITableView *tableView = controller == self.fetchedResultsController ?
                                     self.tableView :
                                     self.searchController.searchResultsTableView;
        [tableView endUpdates];
    }];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type
{
    [self.managedObjectContext performBlockAndWait:^{

        UITableView *tableView = controller == self.fetchedResultsController ?
                                     self.tableView :
                                     self.searchController.searchResultsTableView;

        switch (type)
        {
            case NSFetchedResultsChangeInsert:
                [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
                break;

            case NSFetchedResultsChangeDelete:
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
    }];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)theIndexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.managedObjectContext performBlockAndWait:^{

        UITableView *tableView = controller == self.fetchedResultsController ?
                                     self.tableView :
                                     self.searchController.searchResultsTableView;

        [self showEmptyView:([[controller fetchedObjects] count] == 0)];

        switch (type)
        {
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;

            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeUpdate:
                [self fetchedResultsController:controller
                                 configureCell:[tableView cellForRowAtIndexPath:theIndexPath]
                                   atIndexPath:theIndexPath];
                break;

            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }];
}


#pragma mark -
#pragma mark FetchedResultsController creation

- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString
{
    mustOverride();
}


- (NSString *)sectionKeyPathForSearchableFetchedResultsController:(SQKFetchedTableViewController *)controller
{
    return nil;
}

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSString *sectionKeyPath;
    /**
     *  Only use a sectionKeyPath when not searching becuase:
     *		- A a section index should not be shown while searching, and
     *		- B executed fetch requests take longer when sections are used. When searching this is
     *especially noticable as a new fetch request is executed upon each key stroke during search.
     */
    if (!self.searchIsActive)
    {
        sectionKeyPath = [self sectionKeyPathForSearchableFetchedResultsController:self];
    }
    NSFetchedResultsController *fetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequestForSearch:searchString]
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:sectionKeyPath
                                                       cacheName:nil];
    fetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return fetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    _fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (_searchFetchedResultsController != nil)
    {
        return _searchFetchedResultsController;
    }
    _searchFetchedResultsController =
        [self newFetchedResultsControllerWithSearch:self.searchController.searchBar.text];
    return _searchFetchedResultsController;
}

#pragma mark -
#pragma mark Searching


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.searchIsActive = YES;
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar sizeToFit];
    [searchBar resignFirstResponder];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchIsActive = NO;
    [self searchBarShouldEndEditing:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterContentForSearchText:searchText
                               scope:[self.searchController.searchBar selectedScopeButtonIndex]];
}

- (void)searchBar:(UISearchBar *)searchBar
    selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self filterContentForSearchText:searchBar.text
                               scope:[self.searchController.searchBar selectedScopeButtonIndex]];
}

#pragma mark -
#pragma mark Content Filtering

- (void)reloadFetchedResultsControllers
{
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another
    // with the relevant search info
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

#pragma mark -
#pragma mark Search Bar
- (void)searchController:(UISearchDisplayController *)controller
    willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (BOOL)searchController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[self.searchController.searchBar selectedScopeButtonIndex]];

    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchController.searchBar text]
                               scope:[self.searchController.searchBar selectedScopeButtonIndex]];

    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (void)showEmptyView:(BOOL)show
{
    if (_emptyView)
    {
        if (show)
        {
            _emptyView.center = self.view.center;
            [self.view addSubview:_emptyView];
        }
        else
        {
            [self.emptyView removeFromSuperview];
        }
    }
}


@end

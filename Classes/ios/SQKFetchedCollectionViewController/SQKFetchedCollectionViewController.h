//
//  SQKFetchedCollectionViewController.h
//  Pods
//
//  Created by Ste Prescott on 07/01/2015.
//
//

@import Foundation;
@import CoreData;
@import UIKit;

@interface SQKFetchedCollectionViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate>

/**
 *  Initialises a Core Data-backed UICollectionViewController with a search bar.
 *
 *  @param layout  A required UIColelctionViewLayout instance.
 *  @param context The managed object context to use when query Core Data.
 *
 *  @return An initialized SQKFetchedCollectionViewController object or nil if the object couldn’t be created.
 */
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout context:(NSManagedObjectContext *)context;

/**
 *  Initialises a Core Data-backed UICollectionViewController with the option to remove searching.
 *
 *  @param layout           A required UIColelctionViewLayout instance.
 *  @param context          The managed object context to use when query Core Data.
 *  @param searchingEnabled BOOL that when set to YES sets a search bar is added to the top of the collection view.
 *
 *  @return An initialized SQKFetchedCollectionViewController object or nil if the object couldn’t be created.
 */
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout context:(NSManagedObjectContext *)context searchingEnabled:(BOOL)searchingEnabled;

/**
 *  The collection view shown by the view controller.
 */
@property (strong, nonatomic, readonly) UICollectionView *collectionView;
@property (strong, nonatomic, readonly) UICollectionViewLayout *collectionViewLayout;

/**
 *  An optional refresh control shown when pulling down the collectionview.
 *  Set this in your subclass.
 */
@property (strong, nonatomic) UIRefreshControl *refreshControl;

/**
 *  Show sections when searching. Defaults to NO.
 *
 *  Using a sectionKeyPath when searching is usually not desired, plus
 *  executed fetch requests take longer when sections are used. When searching this is
 *  especially noticable as a new fetch request is executed upon each key stroke during search.
 */
@property (nonatomic, assign) BOOL showsSectionsWhenSearching;

/**
 *  The managed object context backing the fetched results controller.
 */
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

/**
 *  Read only property that allows access to the fetched objects.
 */
@property (strong, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

/**
 *  BOOL that when set to YES sets a search bar is added to the top of the collection view.
 *  Default is set to YES
 */
@property (nonatomic, assign) BOOL searchingEnabled;

/**
 *  Exposing the search bar so it can be customised.
 */
@property (strong, nonatomic, readonly) UISearchBar *searchBar;

/**
 *  Returns YES if the user is actively searching, i.e. the search bar has begun editing. 
 *  Returns NO after the user has cancelled the search.
 */
@property (nonatomic, assign, readonly) BOOL searchIsActive;

/**
 * @name Methods to be overridden in subclass
 */

/**
 *  Configure a item cell for display.
 *  @discussion Override this method in your subclass to customise the appearance of your item cell.
 *  @param cell The item cell to be displayed.
 *  @param indexPath The index path for the item.
 *  @warning This method must be overidden in your subclass.
 */
- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
               configureItemCell:(UICollectionViewCell *)theItemCell
                     atIndexPath:(NSIndexPath *)indexPath;

/**
 *  Returns a new NSFetchRequest for the specified search string.
 *  @discussion Override this method in your subclass to return the appropriate NSFetchRequest for the
 *  search term. If searchString is nil, return your unfiltered dataset.
 *  @param searchString The query entered by a user. May be nil.
 *  @return The NSFetchRequest to be executed by the NSFetchedResultsController.
 *  @warning This method must be overidden in your subclass.
 */
- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString;

/**
 *  Forces the fetched results controller to be recreated, causing performFetch to be fired again.
 *
 *  @param search Search text for the request to be filtered by.
 */
- (void)reloadFetchedResultsControllerForSearch:(NSString *)search;

/**---------------------------------------------------------------------------------------
 * @name Methods that can overridden in subclass, but defaults are used otherwise.
 *  ---------------------------------------------------------------------------------------
 */

/**
 *  Returns the section key path string to use when constructing new NSFetchedResultsControllers.
 *  nil by default, so without overriding NSFetchedResultsControllers will have no sections. NOTE: if
 *  searchIsActive is YES then the return value will be ignored and nil used regardless. This is
 *  because A a section index should not be shown while searching, and B executed fetch requests take
 *  longer when sections are used. When searching this is especially noticable as a new fetch request
 *  is executed upon each key stroke during search.
 *
 *  @param controller The SQKFetchedTableViewController creating the NSFetchedResultsController for
 *  which a sectionKeyPath is needed.
 *
 *  @return The sectionKeyPath to use in constructing a NSFetchedResultsController, or nil for no sections.
 */
- (NSString *)sectionKeyPathForSearchableFetchedResultsController:(SQKFetchedCollectionViewController *)controller;

@end

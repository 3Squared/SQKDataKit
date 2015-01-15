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

@interface SQKFetchedCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate>

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

@end

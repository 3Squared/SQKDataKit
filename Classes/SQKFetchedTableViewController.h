//
//  SQKFetchedTableViewController.h
//  Based on SJOSearchableFetchedResultsController.h
//
//  Created by Sam Oakley on 15/07/2013.
//  Copyright (c) 2013 Sam Oakley. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

/**
This class provides a simpler way to replicate the often-used pattern of a searchable Core Data-backed table view. Must be used as a subclass.
 */
@interface SQKFetchedTableViewController : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate>

/**
 *  Initialises a Core Data-backed UITableViewController with a configured with a UISearchDispalyController.
 *
 *  @param context The managed object context to use when query Core Data.
 *  @param style   A constant that specifies the style of table view that the controller object is to manage (UITableViewStylePlain or UITableViewStyleGrouped).
 *
 *  @return An initialized SJOSearchableFetchedResultsController object or nil if the object couldn’t be created.
 */
- (instancetype)initWithContext:(NSManagedObjectContext *)managedObjectContext style:(UITableViewStyle)style;

/**
 *  The managed object context backing the fetched results controller.
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

/**
 *  Returns YES if the user is actively searching, i.e. the search bar has begun editing. Returns NO after the user has cancelled the search.
 */
@property(nonatomic, assign, readonly) BOOL searchIsActive;

/**
 The UISearchDisplayController used to manage the search interface.
 @discussion You can customise it in your subclass to enable scope buttons, etc.
 */
@property (strong, nonatomic, readonly) UISearchDisplayController *searchController;

@property (strong, nonatomic) UIView *emptyView;

/**
 Returns the currently active UITableView (i.e. regular or search).
 @return The UITableView that is currently active.
 */
-(UITableView*)activeTableView;

/**
 Returns the currently active NSFetchedResultsController (i.e. regular or search).
 @return The NSFetchedResultsController that is currently active.
 */
- (NSFetchedResultsController *)activeFetchedResultsController;


/**
 Returns the appropiate NSFetchedResultsController (i.e. regular or search) for the given UITableView.
 @param tableView The UITableView you wish to retrieve the NSFetchedResultsController for.
 @return The NSFetchedResultsController that is managing the given UITableView.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView;

/**---------------------------------------------------------------------------------------
 * @name Methods to be overridden in subclass
 *  ---------------------------------------------------------------------------------------
 */
/**
 Configure a cell for display.
 @discussion Override this method in your subclass to customise the appearance of your cell.
 @param cell The cell to be displayed.
 @param indexPath The index path for the row.
 @warning This method must be overidden in your subclass.
 */
- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/**
 Returns a new NSFetchRequest for the specified search string.
 @discussion Override this method in your subclass to return the appropriate NSFetchRequest for the search term. If searchString is nil, return your unfiltered dataset.
 @param searchString The query entered by a user. May be nil.
 @return The NSFetchRequest to be executed by the NSFetchedResultsController.
 @warning This method must be overidden in your subclass.
 */
- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString;

/**
Forces the fetched results controllers to be recreated, causing performFetch to be fired again.
 @param fetchedResultsController The NSFetchedResultsController to be reloaded
 */
- (void) reloadFetchedResultsControllers;

/**---------------------------------------------------------------------------------------
 * @name Methods that can overridden in subclass, but defaults are used otherwise.
 *  ---------------------------------------------------------------------------------------
 */
/**
 *  Returns the section key path string to use when constructing new NSFetchedResultsControllers. nil by default, so without overriding NSFetchedResultsControllers will have no sections. NOTE: if `searchIsActive` is YES then the return value will be ignored and nil used regardless. This is because A a section index should not be shown while searching, and B executed fetch requests take longer when sections are used. When searching this is especially noticable as a new fetch request is executed upon each key stroke during search.
 *
 *  @param controller The SJOSearchableFetchedResultsController creating the NSFetchedResultsController for which a sectionKeyPath is needed.
 *
 *  @return The sectionKeyPath to use in constructing a NSFetchedResultsController, or nil for no sections.
 */
- (NSString *)sectionKeyPathForSearchableFetchedResultsController:(SQKFetchedTableViewController *)controller;

@end

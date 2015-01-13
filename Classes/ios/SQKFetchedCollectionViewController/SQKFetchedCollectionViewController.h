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

@interface SQKFetchedCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

/**
 *  The managed object context backing the fetched results controller.
 */
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout context:(NSManagedObjectContext *)context;

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
               configureItemCell:(UICollectionViewCell *)theItemCell
                     atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) BOOL searchingEnabled;
@property (nonatomic, assign, readonly) BOOL searchIsActive;
@property (strong, nonatomic, readonly) UISearchDisplayController *searchController;

- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString;
- (NSFetchedResultsController *)fetchedResultsController;

@end

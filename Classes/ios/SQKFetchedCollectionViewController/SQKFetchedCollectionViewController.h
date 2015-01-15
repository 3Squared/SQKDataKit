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

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL searchingEnabled;
@property (nonatomic, assign, readonly) BOOL searchIsActive;
@property (strong, nonatomic, readonly) UISearchDisplayController *searchController;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout context:(NSManagedObjectContext *)context;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout context:(NSManagedObjectContext *)context searchingEnabled:(BOOL)searchingEnabled;

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
               configureItemCell:(UICollectionViewCell *)theItemCell
                     atIndexPath:(NSIndexPath *)indexPath;

- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString;

@end

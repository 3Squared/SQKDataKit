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

- (NSFetchRequest *)fetchRequest;
- (NSFetchedResultsController *)fetchedResultsController;

@end

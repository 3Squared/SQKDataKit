//
//  SQKFetchedCollectionViewController.m
//  Pods
//
//  Created by Ste Prescott on 07/01/2015.
//
//

#import "SQKFetchedCollectionViewController.h"

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

@interface SQKFetchedCollectionViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *itemChanges;
@end

@implementation SQKFetchedCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout context:(NSManagedObjectContext *)context
{
    self = [super initWithCollectionViewLayout:layout];
    
    if (self)
    {
        self.managedObjectContext = context;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(type)
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
            change[@(type)] = @[indexPath, newIndexPath];
            break;
        }
    }
    
    [_itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView performBatchUpdates:^{
        
        //Deal with the sections
        [self.sectionChanges enumerateObjectsUsingBlock:^(NSDictionary *change, NSUInteger idx, BOOL *stop) {
            
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                
                NSFetchedResultsChangeType type = [key integerValue];
                
                switch(type)
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
                
                switch(type)
                {
                    case NSFetchedResultsChangeInsert:
                    {
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    }
                    case NSFetchedResultsChangeDelete:
                    {
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
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
        
    } completion:^(BOOL finished) {
        self.sectionChanges = nil;
        self.itemChanges = nil;
    }];
}

#pragma mark - FetchedResultsController creation

- (NSFetchRequest *)fetchRequest
{
    mustOverride();
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

@end

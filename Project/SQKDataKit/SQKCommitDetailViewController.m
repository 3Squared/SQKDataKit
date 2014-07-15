//
//  SQKCommitDetailViewController.m
//  SQKDataKit
//
//  Created by Sam Oakley on 07/07/2014.
//  Copyright (c) 2014 3Squared. All rights reserved.
//

#import "SQKCommitDetailViewController.h"
#import "Commit.h"
#import "SQKDataKit.h"

@interface SQKCommitDetailViewController () <SQKManagedObjectControllerDelegate>
@property (nonatomic, strong) Commit *commit;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) SQKManagedObjectController *controller;
@end

@implementation SQKCommitDetailViewController

- (instancetype)initWithCommit:(Commit *)commit
{
    self = [super init];
    if (self)
    {
        self.commit = commit;
        self.title = commit.sha;
        self.controller = [[SQKManagedObjectController alloc] initWithWithManagedObject:commit];
        self.controller.delegate = self;
    }
    return self;
}

- (void)loadView
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];

    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.textView.text = self.commit.message;
    [self.view addSubview:self.textView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                      target:self
                                                      action:@selector(deleteCommit)],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                      target:self
                                                      action:@selector(updateCommit)]
    ];
}


- (void)updateCommit
{
    [self.commit.managedObjectContext performBlock:^{
        self.commit.message = @"This text was updated!";
        [self.commit.managedObjectContext save:nil];
    }];
}

- (void)deleteCommit
{
    [self.commit.managedObjectContext performBlock:^{
        [self.commit.managedObjectContext deleteObject:self.commit];
        [self.commit.managedObjectContext save:nil];
    }];
}

#pragma mark - SQKManagedObjectControllerDelegate

- (void)controller:(SQKManagedObjectController *)controller
    didSaveObjects:(NSIndexSet *)savedObjectIndexes
{
    self.textView.text = self.commit.message;
}

- (void)controller:(SQKManagedObjectController *)controller
    didDeleteObjects:(NSIndexSet *)deletedObjectIndexes
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

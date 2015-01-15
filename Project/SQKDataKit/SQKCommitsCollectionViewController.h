//
//  SQKCommitsCollectionViewController.h
//  SQKDataKit
//
//  Created by Ste Prescott on 07/01/2015.
//  Copyright (c) 2015 3Squared. All rights reserved.
//

#import "SQKFetchedCollectionViewController.h"
#import <SQKDataKit/SQKFetchedCollectionViewController.h>

@class SQKContextManager;

@interface SQKCommitsCollectionViewController : SQKFetchedCollectionViewController

@property (nonatomic, strong) SQKContextManager *contextManager;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout contextManager:(SQKContextManager *)contextManager;

@end

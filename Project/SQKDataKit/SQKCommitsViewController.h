//
//  SQKViewController.h
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQKFetchedTableViewController.h"

@class SQKContextManager;
@interface SQKCommitsViewController : SQKFetchedTableViewController

- (instancetype)initWithContextManager:(SQKContextManager *)contextManager;

@end

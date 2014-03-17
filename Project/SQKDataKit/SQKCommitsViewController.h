//
//  SQKViewController.h
//  SQKDataKit
//
//  Created by Luke Stringer on 04/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SQKCommitsViewController : UITableViewController
@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

- (instancetype)initWithContext:(NSManagedObjectContext *)context;

@end

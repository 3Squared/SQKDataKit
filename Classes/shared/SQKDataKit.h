//
//  SQKDataKit.h
//  SQKDataKit
//
//  Created by Luke Stringer on 05/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKContextManager.h"
#import "NSManagedObject+SQKAdditions.h"
#import "SQKDataImportOperation.h"
#import "NSManagedObjectContext+SQKAdditions.h"
#import "SQKManagedObjectController.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "SQKFetchedTableViewController.h"
#endif
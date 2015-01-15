//
//  SQKDataKit.h
//  SQKDataKit
//
//  Created by Sam Oakley on 15/1/2015.
//  Copyright (c) 2015 3Squared. All rights reserved.
//
#import <Foundation/NSObject.h>

extern NSString *const SQKDataKitErrorDomain;

typedef NS_ENUM(NSInteger, SQKDataKitError)
{
    SQKDataKitErrorUnsupportedQueueConcurencyType, // Returned by the insert-or-update method when a non-private managed object context is used.
    SQKDataKitOperationError, // Generic operation error
    SQKDataKitOperationMultipleErrorsError, // Multiple combined operation errors
    SQKManagedObjectControllerError
};

//
//  CDONotificationManager.m
//  SQKCoreDataOperation Example
//
//  Created by Sam Oakley on 21/10/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import "CDONotificationManager.h"
#import "CDOSynchronisationCoordinator.h"

@implementation CDONotificationManager

+ (void)addObserverForSynchronisationRequestNotification:(id)observer selector:(SEL)aSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:CDOSynchronisationRequestNotification object:nil];
}

+ (void)removeObserverForSynchronisationRequestNotification:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:CDOSynchronisationRequestNotification object:nil];
}

+ (void)addObserverForSynchronisationResponseNotification:(id)observer selector:(SEL)aSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:CDOSynchronisationResponseNotification object:nil];
}

+ (void)removeObserverForSynchronisationResponseNotification:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:CDOSynchronisationResponseNotification object:nil];
}

@end

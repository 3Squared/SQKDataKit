//
//  CDONotificationManager.h
//  SQKCoreDataOperation Example
//
//  Created by Sam Oakley on 21/10/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDONotificationManager : NSObject

+ (void)addObserverForSynchronisationRequestNotification:(id)observer selector:(SEL)aSelector;
+ (void)removeObserverForSynchronisationRequestNotification:(id)observer;

+ (void)addObserverForSynchronisationResponseNotification:(id)observer selector:(SEL)aSelector;
+ (void)removeObserverForSynchronisationResponseNotification:(id)observer;

@end

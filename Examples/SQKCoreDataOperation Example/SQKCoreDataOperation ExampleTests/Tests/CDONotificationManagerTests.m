//
//  CDONotificationManagerTests.m
//  SQKCoreDataOperation Example
//
//  Created by Sam Oakley on 22/10/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CDOSynchronisationCoordinator.h"
#import "CDONotificationManager.h"

@interface CDONotificationManagerTests : XCTestCase
@property (strong, nonatomic) XCTestExpectation *notificationExpectation;
@end

@implementation CDONotificationManagerTests

-(void)tearDown
{
    self.notificationExpectation = nil;
}

- (void)testSynchronisationRequestObserver {
    self.notificationExpectation = [self expectationWithDescription:@"Request notification observed"];
    [CDONotificationManager addObserverForSynchronisationRequestNotification:self selector:@selector(notificationSelector:)];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDOSynchronisationRequestNotification object:nil];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSynchronisationResponseObserver {
    self.notificationExpectation = [self expectationWithDescription:@"Response notification observed"];
    [CDONotificationManager addObserverForSynchronisationResponseNotification:self selector:@selector(notificationSelector:)];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDOSynchronisationResponseNotification object:nil];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) notificationSelector:(NSNotification*)notification {
    [self.notificationExpectation fulfill];
}

@end

//
//  CDOUserImporterTests.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 28/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CDOUserImporter.h"
#import	"SQKContextManager.h"
#import "CDOJSONFixtureLoader.h"
#import "NSManagedObject+SQKAdditions.h"
#import "User.h"

@interface CDOUserImporterTests : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) CDOUserImporter *importer;
@end

@implementation CDOUserImporterTests

- (void)setUp
{
    [super setUp];
    
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	SQKContextManager *contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
																  managedObjectModel:model
																			storeURL:nil];
	self.managedObjectContext = [contextManager newPrivateContext];
	
	self.importer = [[CDOUserImporter alloc] initWithManagedObjectContext:self.managedObjectContext];
    
    NSArray *JSON = [CDOJSONFixtureLoader loadJSONFileNamed:@"users"];
	
	[self.importer importJSON:JSON];
}

- (void)testExample
{
    NSFetchRequest *usersFetchRequest = [User sqk_fetchRequest];
    
    usersFetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", @"lukestringer90"];
    XCTAssertEqual([self.managedObjectContext countForFetchRequest:usersFetchRequest error:NULL], 1, @"");
    
    usersFetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", @"blork"];
    XCTAssertEqual([self.managedObjectContext countForFetchRequest:usersFetchRequest error:NULL], 1, @"");
}

@end

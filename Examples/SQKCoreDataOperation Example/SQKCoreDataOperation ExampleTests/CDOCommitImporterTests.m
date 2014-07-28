//
//  CDOCommitImporterTests.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 27/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CDOCommitImporter.h"
#import	"SQKContextManager.h"
#import "CDOJSONFixtureLoader.h"
#import "NSManagedObject+SQKAdditions.h"
#import "Commit.h"

@interface CDOCommitImporterTests : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) CDOCommitImporter *importer;
@end

@implementation CDOCommitImporterTests

- (void)setUp
{
    [super setUp];
	
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	SQKContextManager *contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
																  managedObjectModel:model
																			storeURL:nil];
	self.managedObjectContext = [contextManager mainContext];
	
	self.importer = [[CDOCommitImporter alloc] initWithManagedObjectContext:self.managedObjectContext];
}

- (void)testImport {
	NSArray *JSON = [CDOJSONFixtureLoader loadJSONFileNamed:@"commits"];
	
	[self.importer importJSON:JSON];
	
	NSFetchRequest *fetchRequest = [Commit sqk_fetchRequest];
	
	XCTAssertEqual([self.managedObjectContext countForFetchRequest:fetchRequest error:NULL], 4, @"");
}

@end

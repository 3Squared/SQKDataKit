//
//  CDOCommitImporterTests.m
//  SQKCoreDataOperation Example
//
//  Created by Luke Stringer on 27/07/2014.
//  Copyright (c) 2014 3Squared Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CDOCommitImporter.h"
#import "SQKContextManager.h"
#import "CDOJSONFixtureLoader.h"
#import "NSManagedObject+SQKAdditions.h"
#import "Commit.h"
#import "User.h"

@interface CDOCommitImporterTests : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) CDOCommitImporter *importer;
@end

@implementation CDOCommitImporterTests

- (void)setUp {
	[super setUp];

	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
	SQKContextManager *contextManager = [[SQKContextManager alloc] initWithStoreType:NSInMemoryStoreType
	                                                              managedObjectModel:model
                                                      orderedManagedObjectModelNames:@[@"SQKCoreDataOperation_Example"]
	                                                                        storeURL:nil];
	self.managedObjectContext = [contextManager newPrivateContext];

	self.importer = [[CDOCommitImporter alloc] initWithManagedObjectContext:self.managedObjectContext];

	NSArray *JSON = [CDOJSONFixtureLoader loadJSONFileNamed:@"commits"];

	[self.importer importJSON:JSON];
}

- (void)testImportCommits {
	NSFetchRequest *commitsFetchRequest = [Commit sqk_fetchRequest];

	XCTAssertEqual([self.managedObjectContext countForFetchRequest:commitsFetchRequest error:NULL], 4, @"");

	commitsFetchRequest.predicate = [NSPredicate predicateWithFormat:@"sha == %@", @"73b03a885f209c66ec61c255f8ea2707a9674dd9"];
	Commit *commit1 = (Commit *)[[self.managedObjectContext executeFetchRequest:commitsFetchRequest error:NULL] firstObject];
	XCTAssertEqualObjects(commit1.message, @"Changed references to `SQKDataImportOperation` to `SQKCoreDataOperation`", @"");

	commitsFetchRequest.predicate = [NSPredicate predicateWithFormat:@"sha == %@", @"3e719a0c5b24f6266af127d2bab5780bea0d2bd7"];
	Commit *commit2 = (Commit *)[[self.managedObjectContext executeFetchRequest:commitsFetchRequest error:NULL] firstObject];
	XCTAssertEqualObjects(commit2.message, @"Merge pull request #8 from 3squared/operation-property-names\n\nOperation property names", @"");

	commitsFetchRequest.predicate = [NSPredicate predicateWithFormat:@"sha == %@", @"fd17de5659d386d0cce4f9465c24ca938374a918"];
	Commit *commit3 = (Commit *)[[self.managedObjectContext executeFetchRequest:commitsFetchRequest error:NULL] firstObject];
	XCTAssertEqualObjects(commit3.message, @"Return correct property value.", @"");

	commitsFetchRequest.predicate = [NSPredicate predicateWithFormat:@"sha == %@", @"8538805da59b243f447fbcd6cf649db90f622c59"];
	Commit *commit4 = (Commit *)[[self.managedObjectContext executeFetchRequest:commitsFetchRequest error:NULL] firstObject];
	XCTAssertEqualObjects(commit4.message, @"Prefixed property names to prevent clashing.", @"");
}

- (void)testImporterUsers {
	NSFetchRequest *usersFetchRequest = [User sqk_fetchRequest];

	XCTAssertEqual([self.managedObjectContext countForFetchRequest:usersFetchRequest error:NULL], 2, @"");

	usersFetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", @"lukestringer90"];
	XCTAssertEqual([self.managedObjectContext countForFetchRequest:usersFetchRequest error:NULL], 1, @"");

	usersFetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", @"blork"];
	XCTAssertEqual([self.managedObjectContext countForFetchRequest:usersFetchRequest error:NULL], 1, @"");
}

@end

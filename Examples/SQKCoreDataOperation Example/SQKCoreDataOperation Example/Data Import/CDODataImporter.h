//
//  CDODataImporter.h
//
//
//  Created by Luke Stringer on 28/07/2014.
//
//

#import <Foundation/Foundation.h>

@interface CDODataImporter : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/**
 *  Must override.
 *
 *  @param JSON JSON to import.
 */
- (void)importJSON:(NSArray *)JSON;

@end

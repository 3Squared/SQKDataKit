//
//  SQKJSONDataImportOperation.h
//  SQKDataKit
//
//  Created by Luke Stringer on 09/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQKJSONDataImportOperation : NSOperation

@property (nonatomic, readonly) NSManagedObjectContext *privateContext;
@property (nonatomic, readonly) id json;

- (instancetype)initWithPrivateContext:(NSManagedObjectContext *)context json:(id)json;

- (void)updatePrivateContext:(NSManagedObjectContext *)context usingJSON:(id)json;

@end

//
//  GitDataImportOperation.h
//  SQKDataKit
//
//  Created by Luke Stringer on 13/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKJSONDataImportOperation.h"

@interface GitDataImportOperation : SQKJSONDataImportOperation

@property (nonatomic, copy, readonly) void (^progressBlock)(NSInteger finishedCount, NSInteger total);

- (instancetype)initWithPrivateContext:(NSManagedObjectContext *)context json:(id)json progressBlock:(void (^)(NSInteger finishedCount, NSInteger total))progressBlock;

@end

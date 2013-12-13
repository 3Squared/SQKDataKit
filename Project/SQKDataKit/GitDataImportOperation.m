//
//  GitDataImportOperation.m
//  SQKDataKit
//
//  Created by Luke Stringer on 13/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "GitDataImportOperation.h"

@interface GitDataImportOperation ()
@property (nonatomic, copy, readwrite) void (^progressBlock)(NSInteger finishedCount, NSInteger total);
@end

@implementation GitDataImportOperation

- (instancetype)initWithPrivateContext:(NSManagedObjectContext *)context json:(id)json progressBlock:(void (^)(NSInteger finishedCount, NSInteger total))progressBlock {
    self = [super initWithPrivateContext:context json:json];
    if (self) {
        self.progressBlock = progressBlock;
    }
    return self;
}

@end

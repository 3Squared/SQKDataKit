//
//  SQKJSONLoader.h
//  SQKDataKit
//
//  Created by Luke Stringer on 23/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKJSONDataImportOperation.h"

@interface SQKJSONLoader : SQKJSONDataImportOperation

+ (id)loadJSONFileName:(NSString *)fileName;

@end

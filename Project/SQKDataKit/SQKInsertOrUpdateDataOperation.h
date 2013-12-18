//
//  SQKInsertOrUpdateDataOperation.h
//  SQKDataKit
//
//  Created by Sam Oakley on 18/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKDataImportOperation.h"
#import "NSManagedObject+SQKAdditions.h"

@interface SQKInsertOrUpdateDataOperation : SQKDataImportOperation
@property (nonatomic, readonly) NSString *uniqueModelKey;
@property (nonatomic, readonly) NSString *uniqueRemoteKey;
@property (nonatomic, assign, readonly) SQKPropertySetterBlock propertySetterBlock;
@end

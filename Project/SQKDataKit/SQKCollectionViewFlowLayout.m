//
//  SQKCollectionViewFlowLayout.m
//  SQKDataKit
//
//  Created by Ste Prescott on 08/01/2015.
//  Copyright (c) 2015 3Squared. All rights reserved.
//

#import "SQKCollectionViewFlowLayout.h"

@implementation SQKCollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.itemSize = CGSizeMake(120, 120);
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 20;
    }
    
    return self;
}

@end

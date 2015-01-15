//
//  SQKCommitItemCell.h
//  SQKDataKit
//
//  Created by Ste Prescott on 07/01/2015.
//  Copyright (c) 2015 3Squared. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SQKCommitItemCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, readonly) UILabel *authorNameLabel;
@property (nonatomic, readonly) UILabel *dateLabel;

@end

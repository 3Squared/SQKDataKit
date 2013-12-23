//
//  SQKCommitCell.h
//  SQKDataKit
//
//  Created by Luke Stringer on 12/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const SQKCommitCellHeight;

@interface SQKCommitCell : UITableViewCell

@property (nonatomic, readonly) UILabel *authorNameLabel;
@property (nonatomic, readonly) UILabel *authorEmailLabel;
@property (nonatomic, readonly) UILabel *dateLabel;
@property (nonatomic, readonly) UILabel *shaLabel;
@property (nonatomic, readonly) UILabel *messageLabel;

@end

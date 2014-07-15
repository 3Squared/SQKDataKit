//
//  SQKCommitCell.m
//  SQKDataKit
//
//  Created by Luke Stringer on 12/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#import "SQKCommitCell.h"

CGFloat const SQKCommitCellHeight = 130.0f;

@interface SQKCommitCell ()
@property (nonatomic, strong, readwrite) UILabel *authorNameLabel;
@property (nonatomic, strong, readwrite) UILabel *authorEmailLabel;
@property (nonatomic, strong, readwrite) UILabel *dateLabel;
@property (nonatomic, strong, readwrite) UILabel *shaLabel;
@property (nonatomic, strong, readwrite) UILabel *messageLabel;
@end

@implementation SQKCommitCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.authorNameLabel = [[UILabel alloc] init];
        self.authorEmailLabel = [[UILabel alloc] init];
        self.dateLabel = [[UILabel alloc] init];
        self.shaLabel = [[UILabel alloc] init];
        self.messageLabel = [[UILabel alloc] init];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.contentView.frame);
    CGFloat height = 20.0f;

    self.authorNameLabel.frame = CGRectMake(8, 8, width, height);
    self.authorEmailLabel.frame = CGRectMake(8, CGRectGetMaxY(self.authorNameLabel.frame) + 4, width, height);
    self.dateLabel.frame = CGRectMake(8, CGRectGetMaxY(self.authorEmailLabel.frame) + 4, width, height);
    self.shaLabel.frame = CGRectMake(8, CGRectGetMaxY(self.dateLabel.frame) + 4, width, height);
    self.messageLabel.frame = CGRectMake(8, CGRectGetMaxY(self.shaLabel.frame) + 4, width, height);

    [self.contentView addSubview:self.authorNameLabel];
    [self.contentView addSubview:self.authorEmailLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.shaLabel];
    [self.contentView addSubview:self.messageLabel];
}

@end

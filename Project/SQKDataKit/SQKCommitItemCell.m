//
//  SQKCommitItemCell.m
//  SQKDataKit
//
//  Created by Ste Prescott on 07/01/2015.
//  Copyright (c) 2015 3Squared. All rights reserved.
//

#define degreesToRadians(x) (M_PI * (x) / 180.0)

static CGFloat animationRotateDegree = 0.8;
static CGFloat animationTranslateX = 1.0;
static CGFloat animationTranslateY = 1.2;

#import "SQKCommitItemCell.h"

@interface SQKCommitItemCell ()
@property (nonatomic, strong, readwrite) UILabel *authorNameLabel;
@property (nonatomic, strong, readwrite) UILabel *dateLabel;
@end

@implementation SQKCommitItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.authorNameLabel = [[UILabel alloc] init];
        self.authorNameLabel.backgroundColor = [UIColor whiteColor];
        self.authorNameLabel.font = [UIFont systemFontOfSize:35];
        self.authorNameLabel.textAlignment = NSTextAlignmentCenter;
        self.authorNameLabel.textColor = [UIColor lightGrayColor];
        self.authorNameLabel.clipsToBounds = YES;
        
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont systemFontOfSize:11];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.authorNameLabel];
        [self addSubview:self.dateLabel];
    }
    
    return self;
}

- (void)setIsEditing:(BOOL)isEditing
{
    _isEditing = isEditing;
    
    if(self.isEditing)
    {
        [self startJiggling];
    }
    else
    {
        [self stopJiggling];
    }
}

- (void)layoutSubviews
{
    CGFloat authorLabelSize = self.frame.size.height - 20;
    
    self.authorNameLabel.frame = CGRectMake(10, 0, authorLabelSize, authorLabelSize);
    self.authorNameLabel.layer.cornerRadius = (authorLabelSize / 2);
    
    self.dateLabel.frame = CGRectMake(5, self.frame.size.height - 20, self.frame.size.width - 10, 20);
}

- (void)startJiggling
{
    CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians(animationRotateDegree * +1));
    CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians(animationRotateDegree * -1));
    CGAffineTransform moveTransform = CGAffineTransformTranslate(rightWobble, -animationTranslateX, -animationTranslateY);
    CGAffineTransform conCatTransform = CGAffineTransformConcat(rightWobble, moveTransform);
    
    self.transform = leftWobble;
    
    CGFloat delay = (((float) rand() / RAND_MAX) * 0.09) + 0.04;
    
    [UIView animateWithDuration:0.1
                          delay:delay
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         self.transform = conCatTransform;
                     }
                     completion:nil];
}

- (void)stopJiggling
{
    [UIView animateWithDuration:0.2 animations:^() {
        self.transform = CGAffineTransformIdentity;
    }
                     completion:^(BOOL finished) {
                         [self.layer removeAllAnimations];
                     }];
}

@end

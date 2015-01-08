//
//  SQKCommitItemCell.m
//  SQKDataKit
//
//  Created by Ste Prescott on 07/01/2015.
//  Copyright (c) 2015 3Squared. All rights reserved.
//

static NSString *animationKey = @"wiggle";

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
        [self startWiggling];
    }
    else
    {
        [self stopWiggling];
    }
}

- (void)layoutSubviews
{
    CGFloat authorLabelSize = self.frame.size.height - 20;
    
    self.authorNameLabel.frame = CGRectMake(10, 0, authorLabelSize, authorLabelSize);
    self.authorNameLabel.layer.cornerRadius = (authorLabelSize / 2);
    
    self.dateLabel.frame = CGRectMake(5, self.frame.size.height - 20, self.frame.size.width - 10, 20);
}



- (void)startWiggling
{
    CAKeyframeAnimation *position = [CAKeyframeAnimation animation];
    position.keyPath = @"position";
    position.values = @[
                        [NSValue valueWithCGPoint:CGPointZero],
                        [NSValue valueWithCGPoint:CGPointMake(-1, 0)],
                        [NSValue valueWithCGPoint:CGPointMake(1, 0)],
                        [NSValue valueWithCGPoint:CGPointMake(-1, 1)],
                        [NSValue valueWithCGPoint:CGPointMake(1, -1)],
                        [NSValue valueWithCGPoint:CGPointZero]
                        ];
    position.timingFunctions = @[
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                 ];
    position.additive = YES;
    
    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animation];
    rotation.keyPath = @"transform.rotation";
    rotation.values = @[
                        @0,
                        @0.03,
                        @0,
                        [NSNumber numberWithFloat:-0.02]
                        ];
    rotation.timingFunctions = @[
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                 ];
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.animations = @[position, rotation];
    group.duration = 0.4;
    group.repeatCount = HUGE_VALF;
    
    [self.layer addAnimation:group forKey:animationKey];
}

- (void)stopWiggling
{
    [UIView animateWithDuration:0.2 animations:^() {
        self.transform = CGAffineTransformIdentity;
    }
                     completion:^(BOOL finished) {
                         [self.layer removeAnimationForKey:animationKey];
                     }];
}

@end

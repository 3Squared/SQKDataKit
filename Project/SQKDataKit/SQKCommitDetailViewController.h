//
//  SQKCommitDetailViewController.h
//  SQKDataKit
//
//  Created by Sam Oakley on 07/07/2014.
//  Copyright (c) 2014 3Squared. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Commit;
@interface SQKCommitDetailViewController : UIViewController
- (instancetype)initWithCommit:(Commit *)commit;
@end

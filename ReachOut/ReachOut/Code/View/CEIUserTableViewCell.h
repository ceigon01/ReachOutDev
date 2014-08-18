//
//  CEIUserTableViewCell.h
//  ReachOut
//
//  Created by Jason Smith on 26.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@class PFUser;

@interface CEIUserTableViewCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;

- (void)configureWithUser:(PFUser *)paramUser;

@end

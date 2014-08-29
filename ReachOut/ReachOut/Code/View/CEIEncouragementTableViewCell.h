//
//  CEIEncouragementTableViewCell.h
//  ReachOut
//
//  Created by Jason Smith on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface CEIEncouragementTableViewCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelDateRead;
@property (nonatomic, weak) IBOutlet UILabel *labelCaption;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintHeightLabelCaption;

@end

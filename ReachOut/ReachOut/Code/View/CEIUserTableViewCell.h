//
//  CEIUserTableViewCell.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 26.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;

@interface CEIUserTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;

- (void)configureWithUser:(PFUser *)paramUser;

@end

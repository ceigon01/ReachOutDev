//
//  CEIEncouragementTableViewCell.m
//  ReachOut
//
//  Created by Jason Smith on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIEncouragementTableViewCell.h"

@implementation CEIEncouragementTableViewCell

- (void)awakeFromNib{
  [super awakeFromNib];
  
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  
  self.imageViewProfile.image = [UIImage imageNamed:@"sheepPhoto"];
  self.imageViewProfile.layer.cornerRadius = self.imageView.frame.size.height * 0.5f;
  self.imageViewProfile.layer.masksToBounds = YES;
  
  self.labelFullName.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
  self.labelCaption.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
  self.labelCaption.numberOfLines = 0;
  
  self.labelDateRead.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
}

@end

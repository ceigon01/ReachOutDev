//
//  CEIGoalTableViewCell.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIGoalTableViewCell.h"
#import "CEIDailyChoresView.h"

@implementation CEIGoalTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
  
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {

    [self setup];
  }
  return self;
}

- (void)awakeFromNib{
  [super awakeFromNib];
  
  [self setup];
}

- (void)setup{
  
  self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
  [self.contentView addSubview:self.scrollView];
}

- (void)configureWithGoal:(PFObject *)paramGoal{
  
  NSLog(@"%@",paramGoal);
}

@end

//
//  CEIDoubleDisclosureCell.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIDoubleDisclosureCell.h"

static CGFloat const kLabelsYOffset = 0.0f;
static CGFloat const kLabelsWidth = 40.0f;
static CGFloat const kLabelsHeightRatio = 0.6f;

@interface CEIDoubleDisclosureCell ()

- (void)setup;

@end

@implementation CEIDoubleDisclosureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
  
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    [self setup];
  }
  
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
  
  self = [super initWithCoder:aDecoder];
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
  
  _labelLowerDetail = [[UILabel alloc] initWithFrame:self.detailTextLabel.frame];
  _labelLowerDetail.text = @"upper";
  _labelLowerDetail.backgroundColor = [UIColor clearColor];
  _labelLowerDetail.textAlignment = NSTextAlignmentRight;
  _labelLowerDetail.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
  [self.contentView addSubview:_labelLowerDetail];
}

- (void)layoutSubviews{
  [super layoutSubviews];
  
  self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x,
                                          0.0f,
                                          self.detailTextLabel.frame.size.width,
                                          self.detailTextLabel.frame.size.height);
  
  self.labelLowerDetail.frame = CGRectMake(self.detailTextLabel.frame.origin.x,
                                           self.detailTextLabel.frame.size.height,
                                           self.detailTextLabel.frame.size.width,
                                           self.contentView.frame.size.height - self.detailTextLabel.frame.size.height);
}

@end

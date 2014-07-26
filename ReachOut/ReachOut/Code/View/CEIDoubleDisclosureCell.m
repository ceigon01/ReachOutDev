//
//  CEIDoubleDisclosureCell.m
//  ReachOut
//
//  Created by Jason Smith on 11.06.2014.
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

- (void)setup{
  
  _labelLowerDetail = [[UILabel alloc] initWithFrame:self.detailTextLabel.frame];
  _labelLowerDetail.text = @"upper";
  _labelLowerDetail.backgroundColor = [UIColor clearColor];
  _labelLowerDetail.textAlignment = NSTextAlignmentRight;
  _labelLowerDetail.font = [UIFont fontWithName:@"Helvetica" size:12];
  _labelLowerDetail.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
  [self.contentView addSubview:_labelLowerDetail];
  
  self.detailTextLabel.backgroundColor = [UIColor clearColor];
  self.labelLowerDetail.backgroundColor = [UIColor clearColor];
  
  self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
  self.labelLowerDetail.textAlignment = NSTextAlignmentCenter;
}

- (void)layoutSubviews{
  [super layoutSubviews];
  
  self.detailTextLabel.frame = CGRectMake(self.contentView.frame.size.width * 0.8f,
                                          self.contentView.frame.size.height * 0.1f,
                                          self.contentView.frame.size.width * 0.2f,
                                          self.contentView.frame.size.height * 0.4f);
  
  self.labelLowerDetail.frame = CGRectMake(self.detailTextLabel.frame.origin.x,
                                           self.detailTextLabel.frame.size.height,
                                           self.detailTextLabel.frame.size.width,
                                           self.contentView.frame.size.height - self.detailTextLabel.frame.size.height);
}

@end

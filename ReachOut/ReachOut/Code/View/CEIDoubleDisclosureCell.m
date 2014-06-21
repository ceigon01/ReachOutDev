//
//  CEIDoubleDisclosureCell.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIDoubleDisclosureCell.h"

static CGFloat const kLabelsYOffset = 40.0f;
static CGFloat const kLabelsWidth = 100.0f;
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

- (void)awakeFromNib{
  [super awakeFromNib];
  
  [self setup];
}

- (void)setup{
  
  _labelCounter = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - kLabelsYOffset - kLabelsWidth,
                                                            0.0f,
                                                            kLabelsWidth,
                                                            self.frame.size.height * kLabelsHeightRatio)];
  _labelCounter.text = @"upper";
  _labelCounter.backgroundColor = [UIColor clearColor];
  _labelCounter.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
  [self.contentView addSubview:_labelCounter];
  
  _labelDate = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - kLabelsYOffset - kLabelsWidth,
                                                         0.0f,
                                                         kLabelsWidth,
                                                         self.frame.size.height * (1.0f - kLabelsHeightRatio))];
  _labelDate.text = @"lower";
  _labelDate.backgroundColor = [UIColor clearColor];
  _labelDate.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
  [self.contentView addSubview:_labelDate];
}

@end

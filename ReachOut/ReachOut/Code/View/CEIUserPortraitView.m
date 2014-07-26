//
//  CEIUserPortraitView.m
//  ReachOut
//
//  Created by Jason Smith on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIUserPortraitView.h"
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

static CGFloat kTextToImageRatio = 0.25f;

@interface CEIUserPortraitView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *labelFullName;

@end

@implementation CEIUserPortraitView

- (id)initWithFrame:(CGRect)frame{
  
  self = [super initWithFrame:frame];
  
  _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                             0.0f,
                                                             frame.size.height * (1.0f - kTextToImageRatio),
                                                             frame.size.height * (1.0f - kTextToImageRatio))];
  _imageView.image = [UIImage imageNamed:@"imgPlaceholder"];
  _imageView.contentMode = UIViewContentModeCenter;
  [self addSubview:_imageView];
  
  _labelFullName = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                             CGRectGetMaxY(_imageView.frame),
                                                             frame.size.width,
                                                             frame.size.height * kTextToImageRatio)];
  _labelFullName.text = @"Full Name";
  _labelFullName.backgroundColor = [UIColor clearColor];
  [self addSubview:_labelFullName];
  
  return self;
}


- (void)setUser:(PFUser *)paramUser{
  
  if (paramUser[@"image"]) {
    
    PFFile *file = paramUser[@"image"];
    
    __weak typeof (self) weakSelf = self;
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
      
      weakSelf.imageView.image = [UIImage imageWithData:data];
      weakSelf.imageView.layer.cornerRadius = weakSelf.imageView.frame.size.height * 0.5f;
      weakSelf.imageView.layer.masksToBounds = YES;
    }];
    
  }
  else{
    
    self.imageView.image = [UIImage imageNamed:@"sheepPhoto"];
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height * 0.5f;
    self.imageView.layer.masksToBounds = YES;
  }

  self.labelFullName = paramUser[@"fullName"];
}

@end

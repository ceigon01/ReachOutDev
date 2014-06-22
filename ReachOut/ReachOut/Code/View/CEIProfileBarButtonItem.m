//
//  CEIProfileBarButtonItem.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 21.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIProfileBarButtonItem.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

static CGSize const kInnerViewSize = {.width = 44.0f, .height = 44.0f};
static CGSize const kImageSize = {.width = 30.0f, .height = 30.0f};

@implementation CEIProfileBarButtonItem

+ (CEIProfileBarButtonItem *)profileBarButtonItemWithImageURL:(NSString *)paramImageURL
                                                     fullName:(NSString *)paramFullName{
  
  UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kInnerViewSize.width - kImageSize.width) * 0.5f,
                                                                         CGPointZero.y,
                                                                         kImageSize.width,
                                                                         kImageSize.height)];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.layer.masksToBounds = YES;
  imageView.layer.cornerRadius = imageView.frame.size.width * 0.5f;
  imageView.backgroundColor = [UIColor clearColor];
  [imageView setImageWithURL:[NSURL URLWithString:paramImageURL]
            placeholderImage:[UIImage imageNamed:@"imgUserPlaceholder"]];
  
  UILabel *labelFullName = [[UILabel alloc] initWithFrame:CGRectMake(CGPointZero.x,
                                                                     CGPointZero.y,
                                                                     kInnerViewSize.width,
                                                                     kInnerViewSize.height - kImageSize.height)];
  labelFullName.text = paramFullName;
  labelFullName.textAlignment = NSTextAlignmentCenter;
  labelFullName.backgroundColor = [UIColor clearColor];
  
  UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(CGPointZero.x,
                                                               CGPointZero.y,
                                                               kInnerViewSize.width,
                                                               kInnerViewSize.height)];
  innerView.backgroundColor = [UIColor clearColor];
  [innerView addSubview:imageView];
  [innerView addSubview:labelFullName];
  
  CEIProfileBarButtonItem *profileBarButtonItem = [[CEIProfileBarButtonItem alloc] initWithCustomView:innerView];
  
  return profileBarButtonItem;
}

@end

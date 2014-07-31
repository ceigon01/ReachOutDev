//
//  UIImage+Crop.m
//  ReachOut
//
//  Created by Jason Smith on 31.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "UIImage+Crop.h"

@implementation UIImage (Crop)

- (UIImage *)imageCroppedWithRect:(CGRect)paramRect{

  CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], paramRect);
  UIImage *img = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  
  return img;
}

@end

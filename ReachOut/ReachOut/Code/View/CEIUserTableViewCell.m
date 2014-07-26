//
//  CEIUserTableViewCell.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 26.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIUserTableViewCell.h"
#import <Parse/Parse.h>

@implementation CEIUserTableViewCell

- (void)awakeFromNib{
  [super awakeFromNib];

  self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.height * 0.5f;
  self.imageViewProfile.layer.masksToBounds = YES;
}

- (void)configureWithUser:(PFUser *)paramUser{

  self.labelFullName.text = paramUser[@"fullName"];
  self.labelTitle.text = paramUser[@"title"];
  
  if (paramUser[@"image"]) {
    
    PFFile *file = paramUser[@"image"];
    
    __weak CEIUserTableViewCell *weakSelf = self;
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
      
      weakSelf.imageViewProfile.image = [UIImage imageWithData:data];
    }];
  }
}

@end

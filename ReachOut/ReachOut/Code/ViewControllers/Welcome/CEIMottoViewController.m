//
//  CEIMottoViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 12.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMottoViewController.h"

@interface CEIMottoViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *labelMotto1;
@property (nonatomic, weak) IBOutlet UILabel *labelMotto2;
@property (nonatomic, weak) IBOutlet UIButton *buttonStartNow;

@end

@interface CEIMottoViewController ()

@end

@implementation CEIMottoViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  self.labelMotto1.textColor = [CEIColor colorDarkText];
  self.labelMotto2.textColor = [CEIColor colorLightText];
}

@end

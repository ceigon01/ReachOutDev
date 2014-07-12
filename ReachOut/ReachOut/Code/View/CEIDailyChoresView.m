//
//  CEIDailyChoresView.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIDailyChoresView.h"
#import "CEIColor.h"
#import <Parse/Parse.h>

@interface CEIDailyChoresView ()

@property (nonatomic, strong) UILabel *labelDay;
@property (nonatomic, strong) UILabel *labelY;
@property (nonatomic, strong) UILabel *labelN;
@property (nonatomic, strong) UIImageView *viewCorner;

@end

@implementation CEIDailyChoresView

- (id)initWithFrame:(CGRect)frame{

  self = [super initWithFrame:frame];
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
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
  tapGestureRecognizer.numberOfTapsRequired = 1;
  [self addGestureRecognizer:tapGestureRecognizer];
  
  self.labelDay = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                            0.0f,
                                                            self.frame.size.width,
                                                            self.frame.size.height * 0.5f)];
  self.labelDay.text = @"day";
  self.labelDay.textAlignment = NSTextAlignmentCenter;
  self.labelDay.backgroundColor = [CEIColor colorIdle];
  self.labelDay.textColor = [UIColor darkGrayColor];
  [self addSubview:self.labelDay];
  
  self.labelY = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                          self.frame.size.height * 0.5f,
                                                          self.frame.size.width * 0.5f,
                                                          self.frame.size.height * 0.5f)];
  self.labelY.text = @"Y";
  self.labelY.textAlignment = NSTextAlignmentCenter;
  self.labelY.backgroundColor = [CEIColor colorIdle];
  self.labelY.textColor = [UIColor darkGrayColor];
  [self addSubview:self.labelY];
  
  self.labelN = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.5f,
                                                          self.frame.size.height * 0.5f,
                                                          self.frame.size.width * 0.5f,
                                                          self.frame.size.height * 0.5f)];
  self.labelN.text = @"N";
  self.labelN.textAlignment = NSTextAlignmentCenter;
  self.labelN.backgroundColor = [CEIColor colorIdle];
  self.labelN.textColor = [UIColor darkGrayColor];
  [self addSubview:self.labelN];
}

- (void)prepareForReuse{
  
  self.labelDay.backgroundColor = [CEIColor colorIdle];
  self.labelY.backgroundColor = [CEIColor colorIdle];
  self.labelN.backgroundColor = [CEIColor colorIdle];
  self.labelDay.textColor = [UIColor darkGrayColor];
  self.labelY.textColor = [UIColor darkGrayColor];
  self.labelN.textColor = [UIColor darkGrayColor];
}

- (void)configureWithGoalStep:(PFObject *)paramGoalStep{
  
  self.goalStep = paramGoalStep;
  self.dayName = paramGoalStep[@"day"];
}

#pragma mark - Action Handling

- (void)tapGesture:(id)paramSender{
  
  if ([self.delegate respondsToSelector:@selector(didTapDailyChoresView:)]) {
    
    [self.delegate didTapDailyChoresView:self];
  }
}

#pragma mark - Custom Getters & Setters

- (void)setDayName:(NSString *)dayName{
  
  if ([dayName isEqualToString:_dayName]) {
    
    return;
  }
  
  _dayName = dayName;
  
  self.labelDay.text = dayName;
}

- (void)setDone:(BOOL)done{

  if (done == _done) {
    
    return;
  }
  
  self.labelDay.textColor = [UIColor whiteColor];
  
  _done = done;
  if (_done) {
    
    self.labelDay.backgroundColor = [CEIColor colorGreen];
    self.labelY.backgroundColor = [CEIColor colorGreen];
    self.labelY.textColor = [UIColor whiteColor];
  }
  else {

    self.labelDay.backgroundColor = [CEIColor colorRed];
    self.labelN.backgroundColor = [CEIColor colorRed];
    self.labelN.textColor = [UIColor whiteColor];
  }
}

- (void)setDate:(NSDate *)date{
  
  _date = date;
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"EEE"];
  self.labelDay.text = [formatter stringFromDate:date];
}

- (void)setComment:(NSString *)comment{
  
  _comment = comment;
  
  if (comment.length == 0) {
    
    [self.viewCorner removeFromSuperview];
    self.viewCorner = nil;
  }
  else
    if (self.viewCorner == nil) {
      
      self.viewCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgCorner"]];
      self.viewCorner.contentMode = UIViewContentModeScaleAspectFit;
      self.viewCorner.frame = CGRectMake(0.0f,
                                         0.0f,
                                         self.labelDay.frame.size.width * 0.25f,
                                         self.labelDay.frame.size.height * 0.5f);
      [self.labelDay addSubview:self.viewCorner];
    }
}

@end

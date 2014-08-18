//
//  CEIDailyChoresView.m
//  ReachOut
//
//  Created by Jason Smith on 22.06.2014.
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
@property (nonatomic, assign) BOOL available;
@property (nonatomic, assign) BOOL today;

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
  
  self.layer.borderColor = [UIColor grayColor].CGColor;
  self.layer.borderWidth = 2.0f;
  
  self.today = NO;
}

- (void)prepareForReuse{
  
  self.labelDay.backgroundColor = [CEIColor colorIdle];
  self.labelY.backgroundColor = [CEIColor colorIdle];
  self.labelN.backgroundColor = [CEIColor colorIdle];
  self.labelDay.textColor = [UIColor darkGrayColor];
  self.labelY.textColor = [UIColor darkGrayColor];
  self.labelN.textColor = [UIColor darkGrayColor];
  
  self.viewCorner.hidden = YES;
  
  _comment = nil;
  _done = NO;
}

- (void)configureWithGoalStep:(PFObject *)paramGoalStep{
  
  self.available = [paramGoalStep[@"available"] boolValue];
  if (self.available) {
    
    self.backgroundColor = [UIColor lightGrayColor];
    self.labelDay.backgroundColor = [UIColor lightGrayColor];
    self.labelN.backgroundColor = [UIColor lightGrayColor];
    self.labelY.backgroundColor = [UIColor lightGrayColor];
  }
  else{
    
    self.backgroundColor = [UIColor whiteColor];
    self.labelDay.backgroundColor = [UIColor whiteColor];
    self.labelN.backgroundColor = [UIColor whiteColor];
    self.labelY.backgroundColor = [UIColor whiteColor];
  }

  NSDateComponents *dateGoalStep = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:paramGoalStep[@"date"]];
  NSDateComponents *dateToday = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
  if (dateGoalStep.day == dateToday.day &&
     dateGoalStep.month == dateToday.month &&
     dateGoalStep.year == dateToday.year){

//    NSLog(@"today:%@ date:%@",dateGoalStep,dateToday);
    
    self.layer.borderColor = [CEIColor colorBlue].CGColor;
    self.layer.borderWidth = 2.0f;
    self.today = YES;
  }
  else{
    
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1.0f;
    self.today = NO;
  }
  
  self.goalStep = paramGoalStep;
  self.dayName = paramGoalStep[@"day"];

  if (self.goalStep[@"done"]) {
    
    BOOL done = [self.goalStep[@"done"] boolValue];
    [self updateWithDone:done comment:self.goalStep[@"caption"]];
  }
}

- (void)updateWithDone:(BOOL)paramDone comment:(NSString *)paramComment{
  
  _comment = paramComment;
  
  self.viewCorner.hidden = (_comment.length == 0);
  
  self.labelDay.textColor = [UIColor whiteColor];
  
  _done = paramDone;
  if (_done) {
    
    self.labelDay.backgroundColor = [CEIColor colorGreen];
    self.labelY.backgroundColor = [CEIColor colorGreen];
    self.labelY.textColor = [UIColor whiteColor];
    self.labelN.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
  }
  else {
    
    self.labelDay.backgroundColor = [CEIColor colorRed];
    self.labelN.backgroundColor = [CEIColor colorRed];
    self.labelN.textColor = [UIColor whiteColor];
    self.labelY.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
  }
}

#pragma mark - Action Handling

- (void)tapGesture:(id)paramSender{
  
  NSDate *date = self.goalStep[@"date"];
  
  NSLog(@"%@",date);
  
  BOOL laterThanToday = ([date timeIntervalSinceDate:[NSDate date]] - 60.0f * 60.0f * 24.0f) > 0;
  
  NSLog(@"%f",[date timeIntervalSinceDate:[NSDate date]]);
  
  if ([self.delegate respondsToSelector:@selector(didTapDailyChoresView:)] &&
      self.available &&
      !laterThanToday) {
    
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

- (void)setDate:(NSDate *)date{
  
  _date = date;
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"EEE"];
  self.labelDay.text = [formatter stringFromDate:date];
}

- (UIImageView *)viewCorner{
  
  if (_viewCorner == nil) {
    
    _viewCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgCorner"]];
    _viewCorner.contentMode = UIViewContentModeScaleAspectFill;
    _viewCorner.frame = CGRectMake(self.labelDay.frame.size.width * 0.75f - self.layer.borderWidth,
                                   0.0f,
                                   self.labelDay.frame.size.width * 0.25f,
                                   self.labelDay.frame.size.height * 0.5f);
    [self.labelDay addSubview:_viewCorner];
  }
  
  return _viewCorner;
}

@end

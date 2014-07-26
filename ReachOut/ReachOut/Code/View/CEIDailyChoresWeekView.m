//
//  CEIDailyChoresWeekView.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 08.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIDailyChoresWeekView.h"
#import "CEIDay.h"
#import <Parse/Parse.h>

const NSInteger kNumberOfDaysInWeek = 7;
static const CGFloat kItemsSpacing = 1.0f;

@interface CEIDailyChoresWeekView () <CEIDailyChoresViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *dictionaryDailyChoresView;

@end

@implementation CEIDailyChoresWeekView

- (instancetype)initWithFrame:(CGRect)frame{
  
  self = [super initWithFrame:frame];
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
  
  CGFloat segmentWidth = (self.frame.size.width - kItemsSpacing*(kNumberOfDaysInWeek+1)) / (CGFloat)kNumberOfDaysInWeek;
  CGFloat segmentOffset = kItemsSpacing;
  
  self.dictionaryDailyChoresView = [[NSMutableDictionary alloc] init];
  for (NSInteger dayCounter = 0; dayCounter < kNumberOfDaysInWeek; dayCounter++) {
    
    CEIDailyChoresView *dailyChoresView = [[CEIDailyChoresView alloc] initWithFrame:CGRectMake(segmentOffset,
                                                                                               0.0f,
                                                                                               segmentWidth,
                                                                                               self.frame.size.height)];
    dailyChoresView.dayName = [CEIDay dayNameWithDayNumber:dayCounter];
    dailyChoresView.delegate = self;
    [self.dictionaryDailyChoresView setObject:dailyChoresView forKey:dailyChoresView.dayName];
    [self addSubview:dailyChoresView];
    segmentOffset += segmentWidth + kItemsSpacing;
  }
}

- (void)configureWithArrayGoalSteps:(NSArray *)arrayGoalSteps{
  
  self.arrayGoalSteps = [NSMutableArray arrayWithArray:arrayGoalSteps];
  
  [self.dictionaryDailyChoresView enumerateKeysAndObjectsUsingBlock:^(NSString *key, CEIDailyChoresView *dailyChoresView, BOOL *stop) {
    
    [dailyChoresView prepareForReuse];
  }];
  
  __weak typeof (self) weakSelf = self;
  
  [arrayGoalSteps enumerateObjectsUsingBlock:^(PFObject *goalStep, NSUInteger idx, BOOL *stop) {

//    CFAbsoluteTime absoluteTime = CFAbsoluteTimeGetCurrent();
//    CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
//    SInt32 dayNumber = CFAbsoluteTimeGetDayOfWeek(absoluteTime, timeZone);
    
//    NSLog(@"%@",[CEIDay dayNameWithDayNumber:dayNumber]);
//    NSLog(@"%@",goalStep);
    
    CEIDailyChoresView *dailyChoresView = [weakSelf.dictionaryDailyChoresView objectForKey:goalStep[@"day"]];
    [dailyChoresView configureWithGoalStep:goalStep];
  }];
}

#pragma mark - CEIDailyChoresView Delegate

- (void)didTapDailyChoresView:(CEIDailyChoresView *)paramDailyChoresView{
  
  [self.delegate dailyChoresWeekView:self didTapDailyChoresView:paramDailyChoresView];
}

@end

//
//  CEIGoalTableViewCell.m
//  ReachOut
//
//  Created by Jason Smith on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIGoalTableViewCell.h"
#import "CEIDailyChoresView.h"
#import "iCarousel.h"
#import "NSDate+Difference.h"
#import "CEIDailyChoresWeekView.h"
#import <Parse/Parse.h>
#import "CEIDay.h"

static const CGFloat kHeightRatioLabelToSelf = 0.3f;

@interface CEIGoalTableViewCell () <iCarouselDataSource, iCarouselDelegate, CEIDailyChoresWeekViewDelegate>

@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) UILabel *labelDatesPeriod;
@property (nonatomic, assign) NSUInteger numberOfDays;
@property (nonatomic, strong) NSArray *arrayGoalSteps;
@property (nonatomic, strong) NSDate *dateStart;
@property (nonatomic, strong) PFObject *mission;

@end

@implementation CEIGoalTableViewCell

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
  
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  
  self.carousel = [[iCarousel alloc] initWithFrame:self.contentView.bounds];
  self.carousel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.carousel.dataSource = self;
  self.carousel.delegate = self;
  self.carousel.decelerationRate = 0.0f;
  [self.contentView addSubview:self.carousel];
  
  self.labelDatesPeriod = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    self.contentView.frame.size.width,
                                                                    self.contentView.frame.size.height * kHeightRatioLabelToSelf)];
  self.labelDatesPeriod.text = @"dates period";
  self.labelDatesPeriod.textAlignment = NSTextAlignmentRight;
  self.labelDatesPeriod.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
  [self.contentView addSubview:self.labelDatesPeriod];
}

- (void)configureWithGoal:(PFObject *)paramGoal mission:(PFObject *)paramMission arrayGoalSteps:(NSArray *)paramGoalSteps{
  
  self.goal = paramGoal;
  self.mission = paramMission;
  self.numberOfDays = [NSDate totalDaysCountForMission:paramMission];
  
  self.arrayGoalSteps = paramGoalSteps;
  
  self.dateStart = paramMission[@"dateBegins"];
  
  [self.carousel reloadData];
  [self carouselDidScroll:self.carousel];
}

- (void)layoutSubviews{
  [super layoutSubviews];
  
  [self.carousel reloadData];
}

#pragma mark - iCarousel DataSource & Delegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
  
  return floor(self.numberOfDays / kNumberOfDaysInWeek);
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
  
  CEIDailyChoresWeekView *dailyChoresWeekView = (CEIDailyChoresWeekView *)view;
  
  if (dailyChoresWeekView == nil){
    
    dailyChoresWeekView = [[CEIDailyChoresWeekView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.height * kHeightRatioLabelToSelf,
                                                                                   0.0f,
                                                                                   self.contentView.frame.size.width,
                                                                                   self.contentView.frame.size.height * (1.0f - kHeightRatioLabelToSelf))];
    dailyChoresWeekView.delegate = self;
  }
  
  NSArray *arrayGoalSteps = [self goalStepsAroundDate:self.dateStart withIndex:index];
  
  __block NSCalendar *calendar = [NSCalendar currentCalendar];
  
  __block NSMutableArray *goalStepsMerged = [NSMutableArray arrayWithArray:arrayGoalSteps];
  
#warning TODO: prearrange the array to make filtering faster
  [self.arrayGoalSteps enumerateObjectsUsingBlock:^(PFObject *goalStep, NSUInteger idx1, BOOL *stop1) {
    
    NSDate *dateStep = goalStep[@"date"];
    NSDateComponents *dateComponentsStep = [calendar components:NSWeekCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:dateStep];
    [arrayGoalSteps enumerateObjectsUsingBlock:^(PFObject *goalStepLocal, NSUInteger idx2, BOOL *stop2) {
      
      NSDate *dateLocal = goalStepLocal[@"date"];
      NSDateComponents *dateComponents = [calendar components:NSWeekCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:dateLocal];
      if (dateComponents.day    == dateComponentsStep.day &&
          dateComponents.month  == dateComponentsStep.month &&
          dateComponents.year   == dateComponentsStep.year) {
        
        NSUInteger index = [goalStepsMerged indexOfObject:goalStepLocal];
        
        if (index != NSNotFound) {
          
          [goalStepsMerged replaceObjectAtIndex:index withObject:goalStep];
        }
        *stop2 = YES;
      }
    }];
  }];
  
  [dailyChoresWeekView configureWithArrayGoalSteps:[NSArray arrayWithArray:goalStepsMerged]];
  
  return dailyChoresWeekView;
}

- (NSArray *)goalStepsAroundDate:(NSDate *)paramDate withIndex:(NSInteger)paramIndex{
  
  __block NSCalendar *calendar = [NSCalendar currentCalendar];
  
  NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit | NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit
                                                 fromDate:self.dateStart];
  
  NSMutableArray *arrayDayOffsets = [[NSMutableArray alloc] init];
  
  for (NSInteger day = 1; day <= dateComponents.weekday-1; day++) {
    
    [arrayDayOffsets addObject:[NSNumber numberWithInteger:(-day)]];
  }
  
  for (NSInteger day = 0; day <= 7 - dateComponents.weekday ; day++) {
    
    [arrayDayOffsets addObject:[NSNumber numberWithInteger:day]];
  }
  
  NSMutableArray *arrayGoalSteps = [[NSMutableArray alloc] init];
  
  for (NSNumber *dayNumber in arrayDayOffsets) {
    
    NSInteger dayOffset = [dayNumber integerValue];

    NSDateComponents *dateComponentsToAdd = [calendar components:NSDayCalendarUnit | NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit
                                                        fromDate:self.dateStart];

    dateComponentsToAdd.day += dayOffset + 1 + (paramIndex * 7);//weeks offset
#warning TODO: ^^ dunno why +1

    NSDate *dateNew = [calendar dateFromComponents:dateComponentsToAdd];

    NSInteger day = [calendar components:NSWeekdayCalendarUnit fromDate:dateNew].weekday;

    PFObject *goalStep = [PFObject objectWithClassName:@"GoalStep"];
    goalStep[@"date"] = dateNew;
    goalStep[@"goal"] = self.goal;
    goalStep[@"mission"] = self.mission;
    goalStep[@"day"] = [CEIDay dayNameWithDayNumber:day-1];

    if ([self.goal[@"isRecurring"] boolValue]) {

      goalStep[@"available"] = @YES;
    }
    else{

      NSArray *arrayDays = self.goal[@"days"];

      if ([arrayDays indexOfObject:goalStep[@"day"]] == NSNotFound) {

        goalStep[@"available"] = @NO;
      }
      else{

        goalStep[@"available"] = @YES;
      }
    }
    
    [arrayGoalSteps addObject:goalStep];
  }
  
  return arrayGoalSteps;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value{
  
  switch (option){
      
    case iCarouselOptionWrap:{
      
      return NO;
    }
      
    case iCarouselOptionSpacing:{

      return value;
    }
      
    case iCarouselOptionFadeMax:{
      
      return value;
    }
      
    default:{
      
      return value;
    }
  }
}

- (void)carouselDidScroll:(iCarousel *)carousel{
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  
  dateFormatter.dateStyle = NSDateFormatterMediumStyle;
  dateFormatter.timeStyle = NSDateFormatterNoStyle;
  
  NSInteger weeksOffset = carousel.currentItemIndex;
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  
  NSDateComponents *dateComponentsStart = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit
                                                      fromDate:self.dateStart];
  
  dateComponentsStart.day += 6 * weeksOffset;
  
  NSDate *dateStart = [calendar dateFromComponents:dateComponentsStart];

  dateComponentsStart.day += 6;

  NSDate *dateFinish = [calendar dateFromComponents:dateComponentsStart];
  
  self.labelDatesPeriod.text = [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:dateStart],[dateFormatter stringFromDate:dateFinish]];
}

#pragma mark - CEIDailyChoresView Delegate

- (void)dailyChoresWeekView:(CEIDailyChoresWeekView *)paramDailyChoresWeekView didTapDailyChoresView:(CEIDailyChoresView *)paramDailyChoresView{
  
  [self.delegateGoalStep goalTableViewCell:self didTapDailyChoresView:paramDailyChoresView];
}

@end

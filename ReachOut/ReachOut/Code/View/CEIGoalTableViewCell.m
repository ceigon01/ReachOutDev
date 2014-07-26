//
//  CEIGoalTableViewCell.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIGoalTableViewCell.h"
#import "CEIDailyChoresView.h"
#import "iCarousel.h"
#import "NSDate+Difference.h"
#import "CEIDailyChoresWeekView.h"
#import <Parse/Parse.h>

static const CGFloat kHeightRatioLabelToSelf = 0.3f;

@interface CEIGoalTableViewCell () <iCarouselDataSource, iCarouselDelegate, CEIDailyChoresWeekViewDelegate>

@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) UILabel *labelDatesPeriod;
@property (nonatomic, assign) NSUInteger numberOfDays;
@property (nonatomic, strong) NSArray *arrayGoalSteps;
@property (nonatomic, strong) NSDate *dateStart;

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

- (void)configureWithGoal:(PFObject *)paramGoal mission:(PFObject *)paramMission{
  
  self.goal = paramGoal;
  self.numberOfDays = [NSDate totalDaysCountForMission:paramMission];
  
  __weak typeof (self) weakSelf = self;
  
  PFRelation *relation = [self.goal relationForKey:@"goalSteps"];
  PFQuery *query = [relation query];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    if (error) {
      
      NSLog(@"%@",error);
    }
    
    weakSelf.arrayGoalSteps = [NSMutableArray arrayWithArray:objects];
    weakSelf.arrayGoalSteps = [weakSelf.arrayGoalSteps sortedArrayUsingComparator:^NSComparisonResult(PFObject *goalStep1, PFObject *goalStep2) {
      
      NSDate *date1 = goalStep1[@"date"];
      NSDate *date2 = goalStep2[@"date"];
      
      return [date1 compare:date2];
    }];
    weakSelf.dateStart = paramMission[@"dateBegins"];
    [weakSelf carouselDidEndDecelerating:weakSelf.carousel];
    [weakSelf.carousel reloadData];
  }];
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
  
  NSMutableArray *arrayGoalSteps = [[NSMutableArray alloc] init];
  for (NSInteger daysCounter = 0; daysCounter<kNumberOfDaysInWeek; daysCounter++) {
    
    NSInteger goalStepIndex = daysCounter + kNumberOfDaysInWeek * index;
    
    if (goalStepIndex >= self.arrayGoalSteps.count) {
      
      break;
    }
    
    [arrayGoalSteps addObject:[self.arrayGoalSteps objectAtIndex:goalStepIndex]];
  }
  
  [dailyChoresWeekView configureWithArrayGoalSteps:[NSArray arrayWithArray:arrayGoalSteps]];
  
  return dailyChoresWeekView;
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

- (void)carouselDidEndDecelerating:(iCarousel *)carousel{
  
#warning TODO: there be some mess here, has to be debuged
  
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

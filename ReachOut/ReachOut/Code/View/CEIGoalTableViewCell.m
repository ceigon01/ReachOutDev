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

@interface CEIGoalTableViewCell () <iCarouselDataSource, iCarouselDelegate, CEIDailyChoresWeekViewDelegate>

@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, assign) NSUInteger numberOfDays;
@property (nonatomic, strong) NSArray *arrayGoalSteps;

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
}

- (void)configureWithGoal:(PFObject *)paramGoal mission:(PFObject *)paramMission goalSteps:(NSArray *)paramArrayGoalSteps{
  
  self.numberOfDays = [NSDate totalDaysCountForMission:paramMission];
  self.arrayGoalSteps = paramArrayGoalSteps;

  [self.carousel reloadData];
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
    
    dailyChoresWeekView = [[CEIDailyChoresWeekView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                   0.0f,
                                                                                   self.contentView.frame.size.width,
                                                                                   self.contentView.frame.size.height)];
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

#pragma mark - CEIDailyChoresView Delegate

- (void)dailyChoresWeekView:(CEIDailyChoresWeekView *)paramDailyChoresWeekView didTapDailyChoresView:(CEIDailyChoresView *)paramDailyChoresView{
  

}

@end

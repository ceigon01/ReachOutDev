//
//  CEIDailyChoresView.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CEIDailyChoresView;

@protocol CEIDailyChoresViewDelegate <NSObject>

@optional
- (void)didTapDailyChoresView:(CEIDailyChoresView *)paramDailyChoresView;

@end

@interface CEIDailyChoresView : UIView

@property (nonatomic, weak) id<CEIDailyChoresViewDelegate> delegate;
@property (nonatomic, assign, getter=isDone) BOOL done;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *comment;

@end
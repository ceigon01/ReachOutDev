//
//  CEICodeVerificationView.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 03.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEICodeVerificationView : UIView

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelSubtitle;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;

@end

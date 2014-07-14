//
//  CEIBaseViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"
#import "UIView+FirstResponder.h"
#import "CRToast.h"
#import "CEIColor.h"

static const NSTimeInterval kTimeDurationViewSlides = 0.22f;
#warning TODO: this suports only iPhone
static const CGFloat kHeightKeyboardHeight = 216.0f;

@interface CEIBaseViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tapToSlideViewToOriginGestureRecognizer;

@end

@implementation CEIBaseViewController

- (void)viewDidLoad{
	[super viewDidLoad];
  
  if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    self.edgesForExtendedLayout = UIRectEdgeNone;
	
	self.slideToOriginAfterTap = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
  [super viewDidDisappear:animated];
  
//  [self slideViewToOrigin];
  
//  [self.view endEditing:YES];
}

- (void)slideViewToInputTextField:(UITextField *)textField{
	
	CGFloat offsetY = CGRectGetMinY(textField.frame) - kHeightKeyboardHeight;// + (self.navigationController.navigationBar.frame.size.height);
  
	if (offsetY > 0.0f) {
    
		[UIView animateWithDuration:kTimeDurationViewSlides
													delay:0.0f
												options:UIViewAnimationOptionCurveEaseInOut
										 animations:^{
											 
											 self.view.frame = CGRectMake(0.0f,
                                                    -offsetY,
                                                    self.view.frame.size.width,
                                                    self.view.frame.size.height);
										 }
										 completion:NULL];
	}
}

- (void)slideViewToOrigin{
	
	[self.view findAndResignFirstResponder];
  
	[UIView animateWithDuration:kTimeDurationViewSlides
												delay:0.0f
											options:UIViewAnimationOptionCurveEaseInOut
									 animations:^{
										 
                     self.view.frame = CGRectMake(0.0f,
                                                  self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height,
                                                  self.view.frame.size.width,
                                                  self.view.frame.size.height);
									 }
									 completion:NULL];
}

#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
  
  [self slideViewToInputTextField:textField];
}

#pragma mark - Convinience Methods

- (void)showToastWithTitle:(NSString *)paramTitle
                  subtitle:(NSString *)paramSubtitle
                   success:(BOOL)paramSuccess{
  
  NSDictionary *options = @{
                            kCRToastTextKey : paramTitle,
                            kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                            kCRToastBackgroundColorKey : paramSuccess ? [CEIColor colorGreen] : [CEIColor colorRed],
                            kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                            kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                            kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionBottom),
                            kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                            kCRToastSubtitleTextKey : paramSubtitle,
                            kCRToastSubtitleTextAlignmentKey : @(NSTextAlignmentLeft),
                            };
  [CRToastManager showNotificationWithOptions:options
                              completionBlock:^{

                              }];
}

#pragma mark - Custom Setters

- (void)setSlideToOriginAfterTap:(BOOL)slideToOriginAfterTap{
	
	if (_slideToOriginAfterTap == NO && slideToOriginAfterTap == YES) {
    
		if (self.tapToSlideViewToOriginGestureRecognizer != nil) {
			
			[self.view removeGestureRecognizer:self.tapToSlideViewToOriginGestureRecognizer];
			self.tapToSlideViewToOriginGestureRecognizer = nil;
		}
		
		self.tapToSlideViewToOriginGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																																													 action:@selector(slideViewToOrigin)];
		[self.view addGestureRecognizer:self.tapToSlideViewToOriginGestureRecognizer];
	}
	else
		if (_slideToOriginAfterTap == YES && slideToOriginAfterTap == NO){
		
			[self.view removeGestureRecognizer:self.tapToSlideViewToOriginGestureRecognizer];
			self.tapToSlideViewToOriginGestureRecognizer = nil;
		}
	
	_slideToOriginAfterTap = slideToOriginAfterTap;
}

#pragma mark - Apperance

- (UIStatusBarStyle)preferredStatusBarStyle{
  
  return UIStatusBarStyleLightContent;
}

@end

//
//  CEIProfilePreviewHeaderView.h
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEIProfilePreviewHeaderView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *labelRelationStatus;
@property (nonatomic, weak) IBOutlet UILabel *labelRole;
@property (nonatomic, weak) IBOutlet UILabel *labelName;

@end

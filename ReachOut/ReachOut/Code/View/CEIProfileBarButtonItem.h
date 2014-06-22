//
//  CEIProfileBarButtonItem.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 21.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEIProfileBarButtonItem : UIBarButtonItem

+ (CEIProfileBarButtonItem *)profileBarButtonItemWithImageURL:(NSString *)paramImageURL
                                                     fullName:(NSString *)paramFullName;

@end

//
//  HEMSenseLearnsView.h
//  Sense
//
//  Created by Jimmy Lu on 7/1/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HEMActionSheetTitleLinkHandler)(NSURL* url);

@interface HEMActionSheetTitleView : UIView

- (instancetype)initWithTitle:(NSString*)title andDescription:(NSAttributedString*)description;
+ (NSAttributedString*)attributedDescriptionFromText:(NSString *)text;
+ (NSDictionary*)defaultDescriptionProperties;
- (void)addLinkHandler:(HEMActionSheetTitleLinkHandler)handler;

@end

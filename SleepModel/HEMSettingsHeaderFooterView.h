//
//  HEMSettingsHeaderFooterView.h
//  Sense
//
//  Created by Jimmy Lu on 11/16/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMSettingsHeaderFooterHeight;
extern CGFloat const HEMSettingsHeaderFooterBorderHeight;
extern CGFloat const HEMSettingsHeaderFooterHeightWithTitle;

@interface HEMSettingsHeaderFooterView : UIView

- (nonnull instancetype)initWithTopBorder:(BOOL)topBorder bottomBorder:(BOOL)bottomBorder;
- (void)setTitle:(nullable NSString*)title;

@end

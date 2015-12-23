//
//  HEMSettingsHeaderFooterView.h
//  Sense
//
//  Created by Jimmy Lu on 11/16/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern CGFloat const HEMSettingsHeaderFooterHeight;
extern CGFloat const HEMSettingsHeaderFooterBorderHeight;
extern CGFloat const HEMSettingsHeaderFooterHeightWithTitle;

@interface HEMSettingsHeaderFooterView : UIView

- (instancetype)initWithTopBorder:(BOOL)topBorder bottomBorder:(BOOL)bottomBorder;
- (void)setTitle:(nullable NSString*)title;
- (void)setAttributedTitle:(NSAttributedString*)attributedTitle;

@end

NS_ASSUME_NONNULL_END

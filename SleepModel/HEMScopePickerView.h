//
//  HEMScopePickerView.h
//  Sense
//
//  Created by Delisa Mason on 1/14/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HEMScopePickerViewDelegate <NSObject>

@required

- (void)didTapButtonWithText:(NSString*)text;
@end

@interface HEMScopePickerView : UIView

- (void)setButtonsWithTitles:(NSArray*)titles selectedIndex:(NSUInteger)selectedIndex;

@property (nonatomic, weak) id<HEMScopePickerViewDelegate> delegate;
@end

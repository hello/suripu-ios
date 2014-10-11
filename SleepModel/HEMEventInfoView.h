//
//  HEMEventInfoView.h
//  Sense
//
//  Created by Delisa Mason on 10/8/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMPaddedRoundedLabel;

typedef NS_ENUM(NSUInteger, HEMEventInfoViewCaretPosition) {
    HEMEventInfoViewCaretPositionTop,
    HEMEventInfoViewCaretPositionMiddle,
    HEMEventInfoViewCaretPositionBottom,
};

@interface HEMEventInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet HEMPaddedRoundedLabel* clockLabel;
@property (nonatomic) HEMEventInfoViewCaretPosition caretPosition;
@end

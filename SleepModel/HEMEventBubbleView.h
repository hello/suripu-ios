//
//  HEMEventBubbleView.h
//  Sense
//
//  Created by Delisa Mason on 5/21/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMEventBubbleView : UIView

+ (CGSize)sizeWithAttributedText:(NSAttributedString *)text timeText:(NSAttributedString *)time;

- (void)setMessageText:(NSAttributedString *)message timeText:(NSAttributedString *)time;
@end

//
//  HEMInsightCardView.h
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HEMInsightDismissBBlock)(void);

@interface HEMInsightCardView : UIView

- (void)setTitle:(NSString*)title andMessage:(NSString*)message;

- (void)showInsightTitle:(NSString*)title
             withMessage:(NSString*)message
                  inView:(UIView*)view
              completion:(void(^)(BOOL finished))completion
            dismissBlock:(HEMInsightDismissBBlock)dismissBlock;

@end

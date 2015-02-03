//
//  HEMBreakdownButton.h
//  Sense
//
//  Created by Delisa Mason on 2/3/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMBreakdownButton : UIButton

- (void)animateDiameterTo:(CGFloat)targetHeight;

@property (nonatomic) NSInteger sleepScore;
@property (nonatomic, getter=isVisible) BOOL visible;
@end

//
//  HEMHandholdingOverlayView.h
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMHHDialogAnchor) {
    HEMHHDialogAnchorTop = 1,
    HEMHHDialogAnchorBottom = 2,
};

@interface HEMHandholdingView : UIView

@property (nonatomic, assign) CGPoint gestureStartCenter;
@property (nonatomic, assign) CGPoint gestureEndCenter;
@property (nonatomic, assign) HEMHHDialogAnchor anchor;
@property (nonatomic, copy)   NSString* message;

- (void)showInView:(UIView*)view;

@end

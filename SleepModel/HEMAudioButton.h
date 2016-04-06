//
//  HEMAudioButton.h
//  Sense
//
//  Created by Jimmy Lu on 4/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMAudioButtonState) {
    HEMAudioButtonStateStopped = 1,
    HEMAudioButtonStateLoading,
    HEMAudioButtonStatePlaying
};

@interface HEMAudioButton : UIButton

@property (nonatomic, assign) HEMAudioButtonState audioState;

@end

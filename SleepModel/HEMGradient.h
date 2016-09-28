//
//  HEMGradient.h
//  Sense
//
//  Created by Jimmy Lu on 12/17/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMGradient : NSObject

@property (nonatomic, assign, readonly) CGGradientRef gradientRef;

+ (HEMGradient*)gradientForTimelineSleepSegment;

- (instancetype)initWithColors:(NSArray*)colors
                     locations:(const CGFloat*)locations NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end
           
NS_ASSUME_NONNULL_END

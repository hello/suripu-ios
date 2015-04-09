//
//  HEMRoomCheckView.h
//  Sense
//
//  Created by Jimmy Lu on 4/6/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMRoomCheckState) {
    HEMRoomCheckStateWaiting = 0,
    HEMRoomCheckStateLoading = 1,
    HEMRoomCheckStateLoaded  = 2
};

@class HEMRoomCheckView;

@protocol HEMRoomCheckDelegate <NSObject>

- (NSUInteger)numberOfSensorsInRoomCheckView:(HEMRoomCheckView*)roomCheckView;
- (UIImage*)sensorIconImageAtIndex:(NSUInteger)sensorIndex
                          forState:(HEMRoomCheckState)state
                   inRoomCheckView:(HEMRoomCheckView*)roomCheckView;
- (NSString*)sensorNameAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView;
- (NSString*)sensorMessageAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView;
- (NSInteger)sensorValueAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView;
- (NSString*)sensorValueUnitAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView;
- (UIColor*)sensorValueColorAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView;

@end

@interface HEMRoomCheckView : UIView

+ (HEMRoomCheckView*)createRoomCheckViewWithFrame:(CGRect)frame;

@property (nonatomic, weak) id<HEMRoomCheckDelegate> delegate;

- (void)animate;

@end

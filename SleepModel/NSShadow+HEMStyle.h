//
//  NSShadow+HEMStyle.h
//  Sense
//
//  Created by Jimmy Lu on 9/8/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSShadow (HEMStyle)

/**
 * @return shadow for the message container of a handholding tutorial
 */
+ (NSShadow*)shadowForHandholdingMessage;

/**
 * @return shadow above the system alert / action views
 */
+ (NSShadow*)shadowForActionView;

/**
 * @return shadow around the cards in the backview
 */
+ (NSShadow*)shadowForBackViewCards;

/**
 * @deprecated use the image found in the common assets catalog instead
 * @return shadow to be shown for button containers to create a divide between
 *         the button and the content.
 */
+ (NSShadow*)shadowForButtonContainer;

/**
 * @return shadow around the trends sleep depth circles
 */
+ (NSShadow*)shadowForTrendsSleepDepthCircles;

/**
 * @return shadow around the alarm and sleep sounds action button
 */
+ (NSShadow*)shadowForCircleActionButton;

@end

NS_ASSUME_NONNULL_END

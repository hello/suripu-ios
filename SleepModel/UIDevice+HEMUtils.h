//
//  UIDevice+HEMUtils.h
//  Sense
//
//  Created by Jimmy Lu on 1/6/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (HEMUtils)

/**
 * @return model of the current device used, which is more descriptive than
 *         simply using UIDevice (iPhone7,2 vs. iPhone)
 */
+ (NSString*)currentDeviceModel;
+ (CGFloat)batteryPercentage;

@end

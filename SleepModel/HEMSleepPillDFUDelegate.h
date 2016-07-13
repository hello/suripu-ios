//
//  HEMSleepPillDFUDelegate.h
//  Sense
//
//  Created by Jimmy Lu on 7/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HEMSleepPillDFUDelegate <NSObject>

- (void)controller:(UIViewController*)dfuController didCompleteDFU:(BOOL)complete;

@end

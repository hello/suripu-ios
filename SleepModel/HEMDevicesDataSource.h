//
//  HEMDevicesDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENDevice;

@interface HEMDevicesDataSource : NSObject <UITableViewDataSource>

/**
 * @property sense: the sense device, if one is paired / linked to the user's
 *                  account
 */
@property (nonatomic, strong, readonly) SENDevice* sense;

/**
 * @property pill: the pill, if one is paired / linked to the user's account
 */
@property (nonatomic, strong, readonly) SENDevice* pill;

/**
 * Refresh the data, loading sense and pill if avaialble
 * @param completion: the completion block to invoke when done
 */
- (void)refresh:(void(^)(void))completion;

@end

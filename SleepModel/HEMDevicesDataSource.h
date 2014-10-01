//
//  HEMDevicesDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENDevice;
@class SENSense;

@interface HEMDevicesDataSource : NSObject <UITableViewDataSource>

/**
 * @property sense: the sense device matching the senseInfo returned
 */
@property (nonatomic, strong, readonly) SENSense* sense;

/**
 * @property senseInfo: the sense device info, if one is paired / linked to the
 *                      user's account
 */
@property (nonatomic, strong, readonly) SENDevice* senseInfo;

/**
 * @property pill: the pill, if one is paired / linked to the user's account
 */
@property (nonatomic, strong, readonly) SENDevice* pillInfo;

/**
 * @property senseLoading: determines whether data source is still currently
 *                         trying to load sense information
 *
 * @discussion
 * If NO, @property sense and @property senseInfo shouldb e populated.  If sense
 * is nil while senseInfo is not nil, then that means Sense is not currently nearby.
 */
@property (nonatomic, assign, readonly, getter=isSenseLoading) BOOL senseLoading;

/**
 * @property senseLoading: determines whether data source is still currently
 *                         trying to load pill information
 */
@property (nonatomic, assign, readonly, getter=isPillLoading) BOOL pillLoading;

/**
 * Refresh the data, loading sense and pill if avaialble
 * @param completion: the completion block to invoke when done
 */
- (void)refresh:(void(^)(void))completion;

@end

//
//  HEMSensorDetailPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"
#import "HEMSensorService.h"

@class SENSensor;

NS_ASSUME_NONNULL_BEGIN

@interface HEMSensorDetailPresenter : HEMPresenter

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService
                            forSensor:(SENSensor*)sensor;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)setPollScope:(HEMSensorServiceScope)scope;

@end

NS_ASSUME_NONNULL_END
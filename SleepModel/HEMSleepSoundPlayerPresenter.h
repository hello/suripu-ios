//
//  HEMSleepSoundPlayerPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 3/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMSleepSoundService;

NS_ASSUME_NONNULL_BEGIN

@class HEMSleepSoundPlayerPresenter;

@protocol HEMSleepSoundPlayerDelegate <NSObject>

- (void)presentError:(NSError*)error;

@end

@interface HEMSleepSoundPlayerPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMSleepSoundPlayerDelegate> delegate;

- (instancetype)initWithSleepSoundService:(HEMSleepSoundService*)service;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithActionButton:(UIButton*)button;

@end

NS_ASSUME_NONNULL_END
//
//  HEMVoiceFeedPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMVoiceService;
@class HEMSubNavigationView;
@class HEMVoiceFeedPresenter;
@class HEMVoiceCommandGroup;
@class HEMActivityIndicatorView;
@class SENVoiceCommandGroup;

@protocol HEMVoiceFeedDelegate <NSObject>

- (void)didTapOnCommandGroup:(SENVoiceCommandGroup*)group
               fromPresenter:(HEMVoiceFeedPresenter*)presenter;

@end

@interface HEMVoiceFeedPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMVoiceFeedDelegate> feedDelegate;

- (instancetype)initWithVoiceService:(HEMVoiceService*)voiceService;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithSubNavigationBar:(HEMSubNavigationView*)subNavBar;
- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator;

@end

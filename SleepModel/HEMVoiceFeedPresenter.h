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

@interface HEMVoiceFeedPresenter : HEMPresenter

- (instancetype)initWithVoiceService:(HEMVoiceService*)voiceService;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithSubNavigationBar:(HEMSubNavigationView*)subNavBar;

@end

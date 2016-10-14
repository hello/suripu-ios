//
//  HEMVoiceExamplesPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMVoiceCommandGroup;

@interface HEMVoiceExamplesPresenter : HEMPresenter

- (instancetype)initWithCommandGroup:(HEMVoiceCommandGroup*)group;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithNavigationBar:(UINavigationBar*)navBar;
- (BOOL)hasNavBar;

@end

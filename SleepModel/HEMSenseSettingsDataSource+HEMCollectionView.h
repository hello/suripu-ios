//
//  HEMSenseSettingsDataSource+HEMCollectionView.h
//  Sense
//
//  Created by Jimmy Lu on 11/18/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMSenseSettingsDataSource.h"

typedef NS_ENUM(NSInteger, HEMSenseAction) {
    HEMSenseActionPairingMode = 0,
    HEMSenseActionEditWiFi = 1,
    HEMSenseActionChangeTimeZone = 2,
    HEMSenseActionAdvanced = 3
};

@interface HEMSenseSettingsDataSource (HEMCollectionView) <UICollectionViewDataSource>

- (CGSize)sizeForItemAtPath:(NSIndexPath*)indexPath inCollectionView:(UICollectionView*)collectionView;

@end

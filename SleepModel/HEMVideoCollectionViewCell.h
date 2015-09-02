//
//  HEMVideoCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 8/28/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMEmbeddedVideoView;

@interface HEMVideoCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet HEMEmbeddedVideoView* videoView;

@end

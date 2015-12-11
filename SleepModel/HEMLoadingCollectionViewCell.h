//
//  HEMLoadingCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 12/8/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMActivityIndicatorView;

@interface HEMLoadingCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;

@end
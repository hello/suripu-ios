//
//  HEMPhotoHeaderView.h
//  Sense
//
//  Created by Jimmy Lu on 5/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMProfileImageView;

@interface HEMPhotoHeaderView : UIView

@property (nonatomic, weak) IBOutlet HEMProfileImageView* imageView;
@property (nonatomic, weak) IBOutlet UIButton* addButton;

@end

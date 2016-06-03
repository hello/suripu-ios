//
//  HEMProfileImageView.h
//  Sense
//
//  Created by Jimmy Lu on 5/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMURLImageView.h"

@class HEMProfileImageView;

@protocol HEMProfileImageLoadDelegate <NSObject>

- (void)willLoadImageIn:(HEMProfileImageView*)imageView;
- (void)didFinishLoadingIn:(HEMProfileImageView*)imageView;

@end

@interface HEMProfileImageView : HEMURLImageView

@property (nonatomic, weak) id<HEMProfileImageLoadDelegate> loadDelegate;

- (void)clearPhoto;
- (BOOL)showingProfilePhoto;

@end

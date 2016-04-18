//
//  HEMSleepSoundConfigurationCell.h
//  Sense
//
//  Created by Jimmy Lu on 3/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@interface HEMSleepSoundConfigurationCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *soundGraphLeftView;
@property (weak, nonatomic) IBOutlet UILabel *playingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *soundGraphRightView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playingLabelTopConstraint;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;

@property (nonatomic, weak) IBOutlet UIView *titleSeparator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleSeparatorHeight;

@property (nonatomic, weak) IBOutlet UIImageView* soundImageView;
@property (nonatomic, weak) IBOutlet UILabel* soundLabel;
@property (nonatomic, weak) IBOutlet UILabel* soundValueLabel;
@property (nonatomic, weak) IBOutlet UIImageView* soundAccessoryView;
@property (nonatomic, weak) IBOutlet UIView *soundSeparator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *soundSeparatorHeight;
@property (nonatomic, weak) IBOutlet UIButton *soundSelectorButton;

@property (nonatomic, weak) IBOutlet UIImageView* durationImageView;
@property (nonatomic, weak) IBOutlet UILabel* durationLabel;
@property (nonatomic, weak) IBOutlet UILabel* durationValueLabel;
@property (nonatomic, weak) IBOutlet UIImageView* durationAccessoryView;
@property (nonatomic, weak) IBOutlet UIView *durationSeparator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *durationSeparatorHeight;
@property (nonatomic, weak) IBOutlet UIButton *durationSelectorButton;

@property (nonatomic, weak) IBOutlet UIImageView* volumeImageView;
@property (nonatomic, weak) IBOutlet UILabel* volumeLabel;
@property (nonatomic, weak) IBOutlet UILabel* volumeValueLabel;
@property (nonatomic, weak) IBOutlet UIImageView* volumeAccessoryView;
@property (nonatomic, weak) IBOutlet UIButton *volumeSelectorButton;

@property (nonatomic, weak) IBOutlet UIView* overlay;

- (void)deactivate:(BOOL)deactivate;
- (void)setPlaying:(BOOL)playing;

@end

//
//  HEMDeviceCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@class HEMActionButton;

@interface HEMDeviceCollectionViewCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastSeenLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastSeenValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *property1Label;
@property (weak, nonatomic) IBOutlet UILabel *property1ValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *property1IconView;
@property (weak, nonatomic) IBOutlet UILabel *property2Label;
@property (weak, nonatomic) IBOutlet UILabel *property2ValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *property2InfoButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *actionButton;

+ (CGFloat)heightOfCellActionButton:(BOOL)hasActionButton;
- (void)showOverlayActivityWithText:(NSString*)text;
- (void)dismissOverlayActivity;
- (void)showDataLoadingIndicator:(BOOL)show;

@end

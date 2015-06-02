//
//  HEMFieldTableViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMSettingsTableViewCell.h"

@class HEMFieldTableViewCell;

@protocol HEMFieldTableViewCellDelegate <NSObject>

- (void)didChangeTextTo:(NSString*)text from:(HEMFieldTableViewCell*)cell;

@end

@interface HEMFieldTableViewCell : HEMSettingsTableViewCell

@property (nonatomic, weak) id<HEMFieldTableViewCellDelegate> delegate;

- (void)setPlaceHolder:(NSString*)text;
- (NSString*)placeHolderText;
- (void)setDefaultText:(NSString*)text;

@end

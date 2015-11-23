//
//  HEMFieldTableViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

@class HEMFieldTableViewCell;

@protocol HEMFieldTableViewCellDelegate <NSObject>

- (void)didChangeTextTo:(NSString*)text from:(HEMFieldTableViewCell*)cell;

@optional
- (void)didTapOnKeyboardReturnKeyFrom:(HEMFieldTableViewCell*)cell;

@end

@interface HEMFieldTableViewCell : UITableViewCell

@property (nonatomic, weak) id<HEMFieldTableViewCellDelegate> delegate;

- (void)setPlaceHolder:(NSString*)text;
- (NSString*)placeHolderText;
- (void)setDefaultText:(NSString*)text;
- (void)setKeyboardType:(UIKeyboardType)keyboardType;
- (void)setKeyboardReturnKeyType:(UIReturnKeyType)returnType;
- (void)setSecure:(BOOL)secure;
- (void)becomeFirstResponder;

@end

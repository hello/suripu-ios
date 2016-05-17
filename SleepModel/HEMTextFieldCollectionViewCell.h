//
//  HEMTextFieldCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 5/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMTextFieldCollectionViewCell : UICollectionViewCell

- (void)setPlaceholderText:(NSString*)placeholderText;
- (void)setSecure:(BOOL)secure;
- (UITextField*)textField;
- (void)update;

@end

NS_ASSUME_NONNULL_END
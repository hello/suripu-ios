//
//  HEMTextFieldCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 5/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMSimpleLineTextField;

NS_ASSUME_NONNULL_BEGIN

@interface HEMTextFieldCollectionViewCell : UICollectionViewCell

- (void)setPlaceholderText:(NSString*)placeholderText;
- (HEMSimpleLineTextField*)textField;

@end

NS_ASSUME_NONNULL_END
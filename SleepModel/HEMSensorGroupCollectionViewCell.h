//
//  HEMSensorGroupCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 9/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMSensorGroupMemberView;

@interface HEMSensorGroupCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *sensorContentView;

+ (CGFloat)heightWithNumberOfMembers:(NSInteger)memberCount
                       conditionText:(NSString*)conditionText
                       conditionFont:(UIFont*)conditionFont
                           cellWidth:(CGFloat)cellWidth;
- (HEMSensorGroupMemberView*)addSensorWithName:(NSString*)name
                                         value:(NSString*)valueText
                                    valueColor:(UIColor*)valueColor;

@end

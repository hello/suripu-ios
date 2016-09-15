//
//  HEMSensorGroupCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 9/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMSensorGroupCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *sensorContentView;

+ (CGFloat)heightWithNumberOfMembers:(NSInteger)memberCount;
- (void)addSensorWithName:(NSString*)name
                    value:(NSString*)valueText
               valueColor:(UIColor*)valueColor;

@end

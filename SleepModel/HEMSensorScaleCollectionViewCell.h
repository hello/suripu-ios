//
//  HEMSensorScaleCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 9/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMSensorScaleCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *measurementLabel;
@property (weak, nonatomic) IBOutlet UIView *scaleContainerView;

@property (assign, nonatomic) NSUInteger numberOfScales;

+ (CGFloat)heightWithNumberOfScales:(NSUInteger)count;
- (void)addScaleWithName:(NSString*)name
                   range:(NSString*)range
          conditionColor:(UIColor*)color;

@end

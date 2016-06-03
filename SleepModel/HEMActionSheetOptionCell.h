//
//  HEMActionSheetOptionCell.h
//  Sense
//
//  Created by Jimmy Lu on 4/22/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMActionSheetOptionCell : UITableViewCell

+ (CGFloat)heightWithTitle:(NSString *)title
               description:(NSString *)description
                  maxWidth:(CGFloat)width;

- (void)setOptionTitle:(NSString*)title
             withColor:(UIColor*)titleColor
                  icon:(UIImage*)icon
           description:(NSString*)description;

- (void)setOptionTitle:(NSString*)title
             withColor:(UIColor*)titleColor
                  icon:(UIImage*)icon
           description:(NSString*)description
         textAlignment:(NSTextAlignment)alignment;

@end

//
//  HEMIntroDescriptionView.h
//  Sense
//
//  Created by Jimmy Lu on 10/14/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMIntroDescriptionView : UIView

+ (instancetype)createDescriptionViewWithFrame:(CGRect)frame
                                         title:(NSString*)title
                                andDescription:(NSString*)description;

@end

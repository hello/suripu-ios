//
//  HEMSlotSpinnerView.h
//  Sense
//
//  Created by Jimmy Lu on 4/13/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMSpinnerView : UIView

- (instancetype)initWithItems:(NSArray*)items font:(UIFont*)font color:(UIColor*)color;

- (void)spinTo:(NSString*)targetItem completion:(void(^)(BOOL finished))completion;

@end

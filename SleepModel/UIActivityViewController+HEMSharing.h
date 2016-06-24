//
//  UIActivityViewController+HEMSharing.h
//  Sense
//
//  Created by Jimmy Lu on 6/23/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityViewController (HEMSharing)

+ (instancetype)share:(id)item ofType:(NSString*)type fromView:(UIView*)view;

@end

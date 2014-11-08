//
//  HEMGraphSectionOverlayView.h
//  Sense
//
//  Created by Delisa Mason on 11/5/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMGraphSectionOverlayView : UIView

- (void)setSectionValues:(NSArray *)sectionValues;

@property (nonatomic, strong) UIColor* topLabelColor;
@property (nonatomic, strong) UIFont* topLabelFont;
@property (nonatomic, strong) UIFont* topLabelBoldFont;
@property (nonatomic, strong) UIColor* bottomLabelColor;
@property (nonatomic, strong) UIFont* bottomLabelFont;
@property (nonatomic, strong) UIFont* bottomLabelBoldFont;
@property (nonatomic, getter=shouldBoldLastElement) BOOL boldLastElement;
@end

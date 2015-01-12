//
//  HEMBaseController+Protected.h
//  Sense
//
//  Created by Jimmy Lu on 8/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMBaseController.h"

@interface HEMBaseController (Protected)

- (void)enableBackButton:(BOOL)enable;
- (void)adjustConstraintsForIPhone4;
- (void)adjustConstraintsForIphone5;
- (void)updateConstraint:(NSLayoutConstraint*)constraint withDiff:(CGFloat)diff;
- (void)showMessageDialog:(NSString*)message title:(NSString*)title;
- (void)showMessageDialog:(NSString*)message title:(NSString*)title image:(UIImage*)image withHelp:(BOOL)help;
- (void)viewDidBecomeActive;
- (BOOL)isIPhone4Family;
- (BOOL)isIPhone5Family;

@end

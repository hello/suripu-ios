//
//  HEMOnboardingController.h
//  Sense
//
//  Created by Jimmy Lu on 1/11/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMBaseController.h"

@interface HEMOnboardingController : HEMBaseController

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;

- (void)enableBackButton:(BOOL)enable;

@end

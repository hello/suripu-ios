//
//  HEMExpansionViewController.h
//  Sense
//
//  Created by Jimmy Lu on 9/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMBaseController.h"

@class SENExpansion;
@class HEMExpansionService;

@interface HEMExpansionViewController : HEMBaseController

@property (nonatomic, strong) SENExpansion* expansion;
@property (nonatomic, strong) HEMExpansionService* expansionService;

@end

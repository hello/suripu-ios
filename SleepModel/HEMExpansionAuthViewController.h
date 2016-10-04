//
//  HEMExpansionAuthViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMBaseController.h"
#import "HEMExpansionConnectDelegate.h"

@class HEMExpansionService;
@class SENExpansion;

@interface HEMExpansionAuthViewController : HEMBaseController

@property (nonatomic, strong) HEMExpansionService* expansionService;
@property (nonatomic, strong) SENExpansion* expansion;
@property (nonatomic, weak) id<HEMExpansionConnectDelegate> connectDelegate;

@end

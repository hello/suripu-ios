//
//  HEMGlobalContants.m
//  Sense
//
//  Created by Jimmy Lu on 10/23/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMGlobalContants.h"

NSInteger ddLogLevel =
#ifdef DEBUG
    DDLogLevelVerbose;
#else
    DDLogLevelError;
#endif

CGFloat const HEMConstantsContentTopMargin = 12.0f;

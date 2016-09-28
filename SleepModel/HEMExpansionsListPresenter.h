//
//  HEMExpansionsListPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 9/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@class HEMExpansionService;

@interface HEMExpansionsListPresenter : HEMPresenter

- (instancetype)initWithExpansionService:(HEMExpansionService*)service;

@end

NS_ASSUME_NONNULL_END
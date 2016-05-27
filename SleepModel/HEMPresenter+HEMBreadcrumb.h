//
//  HEMPresenter+HEMBreadcrumb.h
//  Sense
//
//  Created by Jimmy Lu on 5/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMBreadcrumbService;

@interface HEMPresenter (HEMBreadcrumb)

- (BOOL)breadcrumbService:(HEMBreadcrumbService*)crumbService shouldShowCrumb:(NSString*)crumb;
- (void)breadcrumbService:(HEMBreadcrumbService*)crumbService clearCrumb:(NSString*)crumb;
- (BOOL)breadcrumbService:(HEMBreadcrumbService *)crumbService clearTrailIfEndsIn:(NSString*)crumb;

@end

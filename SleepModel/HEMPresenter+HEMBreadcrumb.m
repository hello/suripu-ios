//
//  HEMPresenter+HEMBreadcrumb.m
//  Sense
//
//  Created by Jimmy Lu on 5/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter+HEMBreadcrumb.h"
#import "HEMBreadcrumbService.h"

@implementation HEMPresenter (HEMBreadcrumb)

- (BOOL)breadcrumbService:(HEMBreadcrumbService*)crumbService shouldShowCrumb:(NSString*)crumb {
    NSString* topCrumb = [crumbService peek];
    return [topCrumb isEqualToString:crumb];
}

- (void)breadcrumbService:(HEMBreadcrumbService*)crumbService clearCrumb:(NSString*)crumb {
    NSString* topCrumb = [crumbService peek];
    if ([topCrumb isEqualToString:crumb]) {
        [crumbService pop];
    }
}

- (void)breadcrumbService:(HEMBreadcrumbService *)crumbService clearTrailIfEndsIn:(NSString*)crumb {
    [crumbService clearIfTrailEndsAt:crumb];
}

@end

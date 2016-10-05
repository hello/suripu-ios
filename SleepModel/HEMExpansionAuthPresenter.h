//
//  HEMExpansionAuthPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"
#import "HEMExpansionConnectDelegate.h"

@class HEMExpansionService;
@class HEMExpansionAuthPresenter;
@class SENExpansionConfig;
@class SENExpansion;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMExpansionAuthDelegate <NSObject>

- (void)didCancelAuthenticationFrom:(HEMExpansionAuthPresenter*)authPresenter;
- (void)showConfigurations:(NSArray<SENExpansionConfig *> *)configs
              forExpansion:(SENExpansion*)expansion
             fromPresenter:(HEMExpansionAuthPresenter *)authPresenter;
- (void)didCompleteAuthenticationFrom:(HEMExpansionAuthPresenter*)authPresenter;

@end

@interface HEMExpansionAuthPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMExpansionAuthDelegate> delegate;
@property (nonatomic, weak) id<HEMExpansionConnectDelegate> connectDelegate;

- (instancetype)initWithExpansion:(SENExpansion*)expansion
                 expansionService:(HEMExpansionService*)expansionService;
- (void)bindWithWebView:(UIWebView*)webView;
- (void)bindWithNavigationItem:(UINavigationItem*)navItem;
- (void)bindWithActivityContainerView:(UIView*)activityContainerView;

@end

NS_ASSUME_NONNULL_END
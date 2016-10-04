//
//  HEMExpansionAuthPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENExpansion.h>

#import "UIBarButtonItem+HEMNav.h"

#import "HEMExpansionAuthPresenter.h"
#import "HEMExpansionService.h"
#import "HEMActivityCoverView.h"
#import "HEMStyle.h"

static CGFloat const kHEMExpansionActionDelay = 1.0f;
static CGFloat const kHEMExpansionActionDelayBeforeLoadingConfigs = 2.0f;

@interface HEMExpansionAuthPresenter() <UIWebViewDelegate>

@property (nonatomic, strong) SENExpansion* expansion;
@property (nonatomic, weak) HEMExpansionService* expansionService;
@property (nonatomic, weak) UIWebView* webView;
@property (nonatomic, weak) UIView* activityContainerView;
@property (nonatomic, strong) HEMActivityCoverView* activityView;
@property (nonatomic, strong) NSArray<SENExpansionConfig*>* configs;
@property (nonatomic, strong) NSURLRequest* authUriRequest;

@end

@implementation HEMExpansionAuthPresenter

- (instancetype)initWithExpansion:(SENExpansion*)expansion
                 expansionService:(HEMExpansionService*)expansionService {
    self = [super init];
    if (self) {
        _expansionService = expansionService;
        _expansion = expansion;
    }
    return self;
}

- (void)bindWithWebView:(UIWebView*)webView {
    NSURLRequest* request = [[self expansionService] authorizationRequestForExpansion:[self expansion]];
    [webView setDelegate:self];
    [webView loadRequest:request];
    [webView setScalesPageToFit:YES];
    [webView setBackgroundColor:[UIColor backgroundColor]];
    [self setWebView:webView];
    [self setAuthUriRequest:request];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    NSString* cancelText = NSLocalizedString(@"actions.cancel", nil);
    UIBarButtonItem* cancel = [UIBarButtonItem cancelItemWithTitle:cancelText
                                                             image:nil
                                                            target:self
                                                            action:@selector(cancel)];
    [navItem setLeftBarButtonItem:cancel];
}

- (void)bindWithActivityContainerView:(UIView*)activityContainerView {
    [self setActivityContainerView:activityContainerView];
}

#pragma mark - Activity

- (void)showActivityWithText:(NSString*)text completion:(void(^)(BOOL finished))completion {
    if ([[self activityView] isShowing]) {
        [[self activityView] updateText:text completion:completion];
    } else {
        HEMActivityCoverView* activityView = [HEMActivityCoverView new];
        [activityView showInView:[self activityContainerView] withText:text activity:YES completion:^{
            if (completion) {
                completion (YES);
            }
        }];
        [self setActivityView:activityView];
    }
}

- (void)dismissActivityWithSucces:(BOOL)success completion:(void(^)(void))completion {
    NSString* successText = nil;
    if (success) {
        successText = NSLocalizedString(@"status.success", nil);
    }
    [[self activityView] dismissWithResultText:successText
                               showSuccessMark:success
                                        remove:YES
                                    completion:completion];
    [self setActivityView:nil];
}

- (void)showAvailableConfigurations {
    __weak typeof(self) weakSelf = self;
    [[self expansionService] getConfigurationsForExpansion:[self expansion] completion:^(NSArray<SENExpansionConfig*>* configs, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setConfigs:configs];
        
        if ([configs count] == 1) {
            // set the config here and end it
            void(^finish)(SENExpansion * expansion, NSError* error) = ^(SENExpansion * expansion, NSError* error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf finishByShowingConfigurations:error != nil];
            };
            
            NSString* configurationName = [[strongSelf expansionService] configurationNameForExpansion:[strongSelf expansion]];
            NSString* updateTextFormat = NSLocalizedString(@"expansion.configuration.activity.updating-config.format", nil);
            NSString* updateText = [NSString stringWithFormat:updateTextFormat, configurationName];
            [[strongSelf activityView] updateText:updateText completion:^(BOOL finished) {
                [[strongSelf expansionService] setConfiguration:[configs firstObject]
                                                   forExpansion:[strongSelf expansion]
                                                     completion:finish];
            }];
        } else {
            [strongSelf finishByShowingConfigurations:YES];
        }
    }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    DDLogVerbose(@"loading web request %@", [request URL]);
    BOOL finished = [[self expansionService] hasExpansion:[self expansion]
                                         connectedWithURL:[request URL]];
    if (finished) {
        __weak typeof(self) weakSelf = self;
        NSString* loadingText = NSLocalizedString(@"expansion.configuration.activity.loading-configs", nil);
        [self showActivityWithText:loadingText completion:^(BOOL finished) {
            [self actionAfterDelay:kHEMExpansionActionDelay action:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [[strongSelf expansionService] refreshExpansion:[strongSelf expansion] completion:^(SENExpansion * expansion, NSError * error) {
                    __weak typeof(weakSelf) strongSelf = weakSelf;
                    if (error || ![[strongSelf expansionService] isConnected:expansion]) {
                        [strongSelf finishByShowingConfigurations:YES];
                    } else {
                        [strongSelf setExpansion:expansion];
                        // FIXME: for some expansions, it takes a little time before
                        // the configurations can be retrieved
                        [strongSelf actionAfterDelay:kHEMExpansionActionDelayBeforeLoadingConfigs action:^{
                            __weak typeof(weakSelf) strongSelf = weakSelf;
                            [strongSelf showAvailableConfigurations];
                        }];
                        
                    }
                }];
            }];
        }];
    }
    return YES;
}

- (void)actionAfterDelay:(CGFloat)delay action:(void(^)(void))action {
    int64_t delayInSecs = (int64_t) delay * NSEC_PER_SEC;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
    dispatch_after(delayTime, dispatch_get_main_queue(), action);
}

#pragma mark - Actions

- (void)cancel {
    [[self connectDelegate] didConnect:NO withExpansion:[self expansion]];
    [[self delegate] didCancelAuthenticationFrom:self];
}

- (void)finishByShowingConfigurations:(BOOL)showConfigurations {
    if (showConfigurations) {
        [[self delegate] showConfigurations:[self configs] fromPresenter:self];
        [self dismissActivityWithSucces:NO completion:nil];
    } else {
        [[self expansion] setState:SENExpansionStateConnectedOn];
        [[self connectDelegate] didConnect:YES withExpansion:[self expansion]];
        
        __weak typeof(self) weakSelf = self;
        NSString* successText = NSLocalizedString(@"status.success", nil);
        UIImage* successIcon = [UIImage imageNamed:@"check"];
        [[self activityView] updateText:successText successIcon:successIcon hideActivity:YES completion:^(BOOL finished) {
            [[self activityView] showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                [self actionAfterDelay:kHEMExpansionActionDelay action:^{
                    __weak typeof(weakSelf) strongSelf = weakSelf;
                    [[strongSelf delegate] didCompleteAuthenticationFrom:strongSelf];
                }];
            }];
        }];
    }
}

#pragma mark - Clean up

- (void)dealloc {
    if (_webView) {
        [_webView setDelegate:nil];
    }
}

@end

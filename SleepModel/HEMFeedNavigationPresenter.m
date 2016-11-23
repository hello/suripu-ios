//
//  HEMFeedContentPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAppUnreadStats.h>

#import "HEMFeedNavigationPresenter.h"
#import "HEMInsightsService.h"
#import "HEMDeviceService.h"
#import "HEMActivityIndicatorView.h"
#import "HEMUnreadAlertService.h"
#import "HEMSubNavigationView.h"
#import "HEMNavigationShadowView.h"
#import "HEMStyle.h"

typedef NS_ENUM(NSUInteger, HEMFeedContentOption) {
    HEMFeedContentOptionInsights = 1,
    HEMFeedContentOptionVoice
};

@interface HEMFeedNavigationPresenter()

@property (nonatomic, weak) HEMActivityIndicatorView* activityView;
@property (nonatomic, weak) HEMUnreadAlertService* unreadService;
@property (nonatomic, weak) UITabBarItem* tabBarItem;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) HEMSubNavigationView* subNavBar;
@property (nonatomic, assign) CGFloat origSubNavHeight;
@property (nonatomic, weak) NSLayoutConstraint* subNavHeightConstraint;
@property (nonatomic, assign) HEMFeedContentOption selectedOption;
@property (nonatomic, assign, getter=isLoadingDeviceInfo) BOOL loadingDeviceInfo;

@end

@implementation HEMFeedNavigationPresenter

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService
                        unreadService:(HEMUnreadAlertService*)unreadService {
    if (self = [super init]) {
        _deviceService = deviceService;
        _unreadService = unreadService;
    }
    return self;
}

- (void)bindWithSubNavigationBar:(HEMSubNavigationView*)subNavgationBar
            withHeightConstraint:(NSLayoutConstraint*)heightConstraint {
    // hide the subnav initially
    [self setOrigSubNavHeight:[heightConstraint constant]];
    [heightConstraint setConstant:0.0f];
    
    [self setSubNavBar:subNavgationBar];
    [self setSubNavHeightConstraint:heightConstraint];
    
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator {
    if ([self isLoadingDeviceInfo]) {
        [activityIndicator start];
        [activityIndicator setHidden:NO];
    } else {
        [activityIndicator setHidden:YES];
    }
    [activityIndicator setUserInteractionEnabled:NO];
    [self setActivityView:activityIndicator];
}

- (void)bindWithTabBarItem:(UITabBarItem*)tabBarItem {
    tabBarItem.title = NSLocalizedString(@"insights.title", nil);
    tabBarItem.image = [UIImage imageNamed:@"senseBarIcon"];
    tabBarItem.selectedImage = [UIImage imageNamed:@"senseBarIconActive"];
    [self setTabBarItem:tabBarItem];
    [self updateTabBarItemUnreadIndicator];
}

- (void)setNavDelegate:(id<HEMFeedNavigationDelegate>)navDelegate {
    _navDelegate = navDelegate;
    [navDelegate showInsightsFrom:self];
}

#pragma mark - Update Navigation

- (void)updateNavigation {
    SENSenseHardware hardware = [[self deviceService] savedHardwareVersion];
    if (hardware == SENSenseHardwareVoice) {
        // show the nav
        [[self subNavBar] setHidden:NO];
        [[self subNavHeightConstraint] setConstant:[self origSubNavHeight]];
        [[self subNavBar] addControl:[self navButtonWithOption:HEMFeedContentOptionInsights selected:YES]];
        [[self subNavBar] addControl:[self navButtonWithOption:HEMFeedContentOptionVoice selected:NO]];
        [[self subNavBar] setNeedsDisplay];
    } else {
        [self updateFeedTo:HEMFeedContentOptionInsights];
        [[self subNavBar] setHidden:YES];
        [[self subNavHeightConstraint] setConstant:0.0f];
        [[self subNavBar] layoutIfNeeded];
    }
}

#pragma mark - Load info

- (void)updateUI {
    SENSenseHardware hardware = [[self deviceService] savedHardwareVersion];
    if (hardware == SENSenseHardwareUnknown) {
        [self setLoadingDeviceInfo:YES];
        [[self activityView] start];
        [[self activityView] setHidden:NO];
        
        __weak typeof(self) weakSelf = self;
        [[self deviceService] refreshMetadata:^(SENPairedDevices * devices, NSError * error) {
            __strong  typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setLoadingDeviceInfo:NO];
            [[strongSelf activityView] stop];
            [[strongSelf activityView] setHidden:YES];
            [strongSelf updateNavigation];
        }];
    } else {
        [self updateNavigation];
    }
}

#pragma mark - Presenter events

- (void)willAppear {
    [super willAppear];
    [self updateUI];
}

- (void)willDisappear {
    [super willDisappear];
    [self updateTabBarItemUnreadIndicator];
}

#pragma mark -

- (void)updateTabBarItemUnreadIndicator {
    if ([self tabBarItem]) {
        __weak typeof(self) weakSelf = self;
        [[self unreadService] update:^(BOOL hasUnread, NSError *error) {
            [weakSelf updateBadge];
        }];
    }
}

- (void)updateBadge {
    SENAppUnreadStats* unreadStats = [[self unreadService] unreadStats];
    BOOL hasUnreadFeedItems = [unreadStats hasUnreadInsights] || [unreadStats hasUnreadQuestions];
    [[self tabBarItem] setBadgeValue:hasUnreadFeedItems ? @"1" : nil];
}

- (UIButton*)navButtonWithOption:(HEMFeedContentOption)option selected:(BOOL)selected {
    NSString* title = nil;
    if (option == HEMFeedContentOptionInsights) {
        title = [NSLocalizedString(@"insights.title", nil) uppercaseString];
    } else {
        title = [NSLocalizedString(@"voice.title", nil) uppercaseString];
    }
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont h7Bold]];
    [button setTitleColor:[UIColor subNavActiveTitleColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor subNavActiveTitleColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor subNavInactiveTitleColor] forState:UIControlStateNormal];
    [button setSelected:selected];
    [button setTag:option];
    [button addTarget:self action:@selector(changeOption:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Actions

- (void)changeOption:(UIButton*)navButton {
    [self updateFeedTo:[navButton tag]];
}

- (void)updateFeedTo:(HEMFeedContentOption)option {
    if ([self selectedOption] != option) {
        DDLogVerbose(@"change option %ld", option);
        [self setSelectedOption:option];
        [[[self subNavBar] shadowView] reset];
        [self updateTabBarItemUnreadIndicator];
        
        switch ([self selectedOption]) {
            case HEMFeedContentOptionInsights:
                return [[self navDelegate] showInsightsFrom:self];
            case HEMFeedContentOptionVoice:
                return [[self navDelegate] showVoiceFrom:self];
            default:
                return;
        }
    }
}

@end

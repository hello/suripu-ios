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

@property (nonatomic, weak) HEMUnreadAlertService* unreadService;
@property (nonatomic, weak) UITabBarItem* tabBarItem;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) HEMSubNavigationView* subNavBar;
@property (nonatomic, assign) CGFloat origSubNavHeight;
@property (nonatomic, weak) NSLayoutConstraint* subNavHeightConstraint;
@property (nonatomic, assign) HEMFeedContentOption selectedOption;

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

    SENSenseHardware hardware = [[self deviceService] savedHardwareVersion];
    if (hardware != SENSenseHardwareVoice) {
        // hide the subnav
        [self setOrigSubNavHeight:[heightConstraint constant]];
        [heightConstraint setConstant:0.0f];
    } else {
        [self setSelectedOption:HEMFeedContentOptionInsights];
        [subNavgationBar addControl:[self navButtonWithOption:HEMFeedContentOptionInsights selected:YES]];
        [subNavgationBar addControl:[self navButtonWithOption:HEMFeedContentOptionVoice selected:NO]];
        [subNavgationBar setNeedsDisplay];
    }
    
    [self setSubNavBar:subNavgationBar];
    [self setSubNavHeightConstraint:heightConstraint];
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

#pragma mark - Presenter events

- (void)willDisappear {
    [super willDisappear];
    [self updateTabBarItemUnreadIndicator];
}

#pragma mark -

- (void)updateTabBarItemUnreadIndicator {
    if ([self tabBarItem]) {
        // since the service is shared, if the last viewed is updated, the stats
        // will to, so we don't need to ask the service to update again.  Also
        // because the SnazzBarController indirectly depends on the tabBarItem,
        // updating the tabBar doesn't really have an effect immediately, which
        // is partially why we don't want to make an async call here
        
        SENAppUnreadStats* unreadStats = [[self unreadService] unreadStats];
        if (unreadStats) {
            [self updateBadge];
        } else {
            __weak typeof(self) weakSelf = self;
            [[self unreadService] update:^(BOOL hasUnread, NSError *error) {
                [weakSelf updateBadge];
            }];
        }
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
    [[button titleLabel] setFont:[UIFont subNavTitleTextFont]];
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
    if ([self selectedOption] != [navButton tag]) {
        DDLogVerbose(@"change option %ld", [navButton tag]);
        [self setSelectedOption:[navButton tag]];
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

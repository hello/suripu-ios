//
//  HEMSensorDetailSubNavPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSensor.h>

#import "HEMSensorDetailSubNavPresenter.h"
#import "HEMSensorService.h"
#import "HEMSubNavigationView.h"
#import "HEMStyle.h"

static NSUInteger const kHEMSensorDetailSubNavTagOffset = 1;

@interface HEMSensorDetailSubNavPresenter()

@property (nonatomic, weak) HEMSensorService* sensorService;
@property (nonatomic, weak) HEMSubNavigationView* subNav;
@property (nonatomic, weak) UINavigationBar* navBar;

@end

@implementation HEMSensorDetailSubNavPresenter

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService {
    if (self = [super init]) {
        _sensorService = sensorService;
        _scopeSelected = HEMSensorServiceScopeDay;
    }
    return self;
}

- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNav {
    [subNav addControl:[self scopeButtonForTimeScope:HEMSensorServiceScopeDay]];
    [subNav addControl:[self scopeButtonForTimeScope:HEMSensorServiceScopeWeek]];
    [self setSubNav:subNav];
    [self bindWithShadowView:[subNav shadowView]];
}

- (void)bindWithNavBar:(UINavigationBar*)navBar {
    [navBar setShadowImage:[UIImage new]];
    [self setNavBar:navBar];
}

- (BOOL)hasNavBar {
    return [self navBar] != nil;
}

- (NSString*)subNavTitleForScope:(HEMSensorServiceScope)scope {
    switch (scope) {
        case HEMSensorServiceScopeWeek:
            return [NSLocalizedString(@"sensor.scope.week", nil) uppercaseString];
        default:
            return [NSLocalizedString(@"sensor.scope.day", nil) uppercaseString];
    }
}

- (UIButton*)scopeButtonForTimeScope:(HEMSensorServiceScope)scope {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitle:[self subNavTitleForScope:scope] forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont button]];
    [button setTitleColor:[UIColor subNavActiveTitleColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor subNavActiveTitleColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor subNavInactiveTitleColor] forState:UIControlStateNormal];
    [button setSelected:scope == [self scopeSelected]];
    [button setTag:scope + kHEMSensorDetailSubNavTagOffset]; // offset needed to avoid finding views with tag of 0
    [button addTarget:self
               action:@selector(changeScope:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)changeScope:(UIButton*)button {
    HEMSensorServiceScope scope = [button tag] - kHEMSensorDetailSubNavTagOffset;
    DDLogVerbose(@"changed sensor scope to %ld", (long)scope);
    [[self delegate] didChangeScopeTo:scope fromPresenter:self];
}
#pragma mark - Presenter Events

- (void)didRelayout {
    [super didRelayout];
    [[self subNav] setNeedsLayout];
}

- (void)didDisappear {
    [super didDisappear];
    [[self navBar] setShadowImage:[UIImage imageNamed:@"navBorder"]];
}

@end

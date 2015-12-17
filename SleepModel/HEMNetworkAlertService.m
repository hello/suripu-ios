//
//  HEMNetworkAlertService.m
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <SenseKit/SENAPIClient.h>

#import "HEMNetworkAlertService.h"

@interface HEMNetworkAlertService()

@property (nonatomic, assign, getter=isNetworkReachable) BOOL networkReachable;

@end

@implementation HEMNetworkAlertService

- (instancetype)init {
    self = [super init];
    if (self) {
        _networkReachable = [SENAPIClient isAPIReachable];
        [self listenForInternetConnectivityChanges];
    }
    return self;
}

- (void)listenForInternetConnectivityChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(networkChanged:)
                   name:SENAPIUnreachableNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(networkChanged:)
                   name:SENAPIReachableNotification
                 object:nil];
}

- (void)networkChanged:(NSNotification*)notification {
    NSString* name = [notification name];
    BOOL changed = NO;
    
    if ([name isEqualToString:SENAPIUnreachableNotification]) {
        changed = [self isNetworkReachable];
    } else if ([name isEqualToString:SENAPIReachableNotification]) {
        changed = ![self isNetworkReachable];
    }
    
    if (changed) {
        [self setNetworkReachable:![self isNetworkReachable]];
        [[self delegate] networkService:self
                  detectedNetworkChange:[self isNetworkReachable]];
    }
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//
//  HEMLocationCenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/20/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "HEMLocationCenter.h"
#import "NSString+UUID.h"

static NSString* const kHEMLocationErrorDomain = @"is.hello.location";

@interface HEMLocationCenter()

@property (nonatomic, strong) CLLocationManager* manager;
@property (nonatomic, strong) NSMutableDictionary* successBlocks;
@property (nonatomic, strong) NSMutableDictionary* failureBlocks;

@end

@implementation HEMLocationCenter

+ (id)sharedCenter {
    static HEMLocationCenter* locationCenter = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        locationCenter = [[super allocWithZone:NULL] init];
    });
    return locationCenter;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedCenter];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setSuccessBlocks:[NSMutableDictionary dictionary]];
        [self setFailureBlocks:[NSMutableDictionary dictionary]];
        [self setManager:[[CLLocationManager alloc] init]];
        [[self manager] setDelegate:self];
    }
    return self;
}

- (NSError*)checkAuthorizationError {
    NSError* error = nil;
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            error = [NSError errorWithDomain:kHEMLocationErrorDomain
                                        code:HEMLocationErrorCodeNotAuthorized
                                    userInfo:nil];
            break;
        }
        default:
            break;
    }
    return error;
}

- (NSString*)locate:(NSError**)locationError
            success:(HEMLocationSuccessBlock)success
            failure:(HEMLocationFailureBlock)failure {
    
    NSError* error = nil;
    NSString* uuid = nil;
    
    if (![CLLocationManager locationServicesEnabled]) {
        error = [NSError errorWithDomain:kHEMLocationErrorDomain
                                    code:HEMLocationErrorCodeNotEnabled
                                userInfo:nil];
    }

    error = [self checkAuthorizationError];
    if (error != nil) {
        if (locationError != NULL) {
            *locationError = error;
        }
    } else {
        uuid = [NSString uuid];
        if (success) {
            [[self successBlocks] setValue:[success copy] forKey:uuid];
        }
        if (failure) {
            [[self failureBlocks] setValue:[failure copy] forKey:uuid];
        }
        [[self manager] startUpdatingLocation];
    }
    
    return uuid;
}

- (void)stopLocatingFor:(NSString*)distinctId {
    if ([distinctId length] == 0) return;
    [[self successBlocks] removeObjectForKey:distinctId];
    [[self failureBlocks] removeObjectForKey:distinctId];
    if ([[self successBlocks] count] == 0 && [[self failureBlocks] count] == 0) {
        [[self manager] stopUpdatingLocation];
    }
}

#pragma mark - Delegate -

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if ([[self successBlocks] count] == 0)  return;
    CLLocation* latestLocation = [locations lastObject];
    NSArray* blocks = [[self successBlocks] allValues];
    for (HEMLocationSuccessBlock block in blocks) {
        block(latestLocation.coordinate.latitude,
              latestLocation.coordinate.longitude,
              latestLocation.horizontalAccuracy);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([[self failureBlocks] count] == 0)  return;
    NSArray* blocks = [[self failureBlocks] allValues];
    for (HEMLocationFailureBlock block in blocks) {
        block(error);
    }
}

@end

//
//  HEMLocationService.m
//  Sense
//
//  Created by Jimmy Lu on 6/7/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>

#import "HEMLocationService.h"

NSString* const HEMLocationErrorDomain = @"is.hello.location";

@interface HEMLocation()

@property (nonatomic, assign) CGFloat lat;
@property (nonatomic, assign) CGFloat lon;
@property (nonatomic, assign) CGFloat horizontalAccuracy;
@property (nonatomic, assign) CGFloat verticalAccuracy;

@end

@implementation HEMLocation

- (instancetype)initWithLocation:(CLLocation*)location {
    self = [super init];
    if (self) {
        _lat = [location coordinate].latitude;
        _lon = [location coordinate].longitude;
        _horizontalAccuracy = [location horizontalAccuracy];
        _verticalAccuracy = [location verticalAccuracy];
    }
    return self;
}

@end

@interface HEMLocationActivity()

@property (nonatomic, copy) NSString* identifier;
@property (nonatomic, copy) HEMLocationHandler callback;

@end

@implementation HEMLocationActivity

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [[[NSUUID UUID] UUIDString] copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[HEMLocationActivity class]]) {
        return NO;
    }
    return [[self identifier] isEqualToString:[object identifier]];
}

- (NSUInteger)hash {
    return [[self identifier] hash];
}

@end

@interface HEMLocationService() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSMutableArray<HEMLocationActivity*>* activities;

@end

@implementation HEMLocationService

- (instancetype)init {
    self = [super init];
    if (self) {
        _activities = [NSMutableArray array];
        _locationManager = [CLLocationManager new];
        [_locationManager setDelegate:self];
    }
    return self;
}

- (HEMLocationAuthStatus)authorizationStatus {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            return HEMLocationAuthStatusUnknown;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            return HEMLocationAuthStatusDenied;
        default:
            return HEMLocationAuthStatusAuthorized;
    }
}

- (NSError*)errorWithCode:(HEMLocationErrorCode)code {
    NSDictionary* info = nil;
    NSString* description = nil;
    switch (code) {
        case HEMLocationErrorCodeNotEnabled:
            description = @"location services is not enabled";
            break;
        default:
            break;
    }
    if (description) {
        info = @{NSLocalizedDescriptionKey : description};
    }
    return [NSError errorWithDomain:HEMLocationErrorDomain
                               code:code
                           userInfo:info];
}

- (NSError*)errorFromStartingLocation {
    NSError* error = nil;
    if (![CLLocationManager locationServicesEnabled]) {
        error = [self errorWithCode:HEMLocationErrorCodeNotEnabled];
    } else if ([self authorizationStatus] == HEMLocationAuthStatusDenied) {
        error = [self errorWithCode:HEMLocationErrorCodeDenied];
    }
    return error;
}

- (HEMLocationActivity*)startLocationActivity:(HEMLocationHandler)update error:(NSError**)error {
    NSError* initialError = [self errorFromStartingLocation];
    if (initialError) {
        if (error != NULL) {
            *error = initialError;
        }
        [SENAnalytics trackError:initialError withEventName:kHEMAnalyticsEventWarning];
        return nil;
    }
    
    HEMLocationActivity* activity = [HEMLocationActivity new];
    [activity setCallback:update];
    
    if ([[self activities] count] == 0) {
        [[self locationManager] startUpdatingLocation];
    }
    
    [[self activities] addObject:activity];
    
    return activity;
}

- (void)stopLocationActivity:(HEMLocationActivity*)activity {
    if (activity) {
        [[self activities] removeObject:activity];
        if ([[self activities] count] == 0) {
            [[self locationManager] stopUpdatingLocation];
        }
    }
}

- (void)callActivitiesWithLocation:(HEMLocation*)location error:(NSError*)error {
    if ([[self activities] count] == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        for (HEMLocationActivity* activity in [strongSelf activities]) {
            [activity callback] (location, error);
        }
    });
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    HEMLocationAuthStatus localStatus = [self authorizationStatus];
    if (localStatus == HEMLocationAuthStatusDenied && [[self activities] count] > 0) {
        NSError* error = [self errorWithCode:HEMLocationErrorCodeDenied];
        [SENAnalytics trackError:error];
        [self callActivitiesWithLocation:nil error:error];
    } else if (localStatus == HEMLocationAuthStatusUnknown) {
        [[self locationManager] requestWhenInUseAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation* coreLocation = [locations lastObject];
    if (coreLocation && [[self activities] count] > 0) {
        HEMLocation* location = [[HEMLocation alloc] initWithLocation:coreLocation];
        [self callActivitiesWithLocation:location error:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([[self activities] count] > 0) {
        [SENAnalytics trackError:error];
        [self callActivitiesWithLocation:nil error:error];
    }
}

#pragma mark - Clean up

- (void)dealloc {
    if (_locationManager) {
        [_locationManager stopUpdatingLocation];
        [_locationManager setDelegate:nil];
    }
}

@end

//
//  HEMZendeskService.m
//  Sense
//
//  Created by Jimmy Lu on 6/4/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENServiceAccount.h>
#import <SenseKit/SENAccount.h>

#import <ZendeskSDK/ZendeskSDK.h>

#import "HEMZendeskService.h"
#import "HEMSupportUtil.h"
#import "HEMConfig.h"

// the following are values found in the Zendesk admin interface that maps
// to the custom fields created

// static long const HEMZendeskCustomFieldIdFirmware = 24385215;
static long const HEMZendeskCustomFieldIdOSVersion = 24385205;
static long const HEMZendeskCustomFieldIdDeviceModel = 24385195;
static long const HEMZendeskCustomFieldIdAccountId = 24385185;

@interface HEMZendeskService()

@property (nonatomic, assign) BOOL configured;

@end

@implementation HEMZendeskService

+ (id)sharedService {
    static HEMZendeskService* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super allocWithZone:NULL] init];
    });
    return service;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedService];
}

- (void)configure:(void(^)(NSError* error))completion {
    if ([self configured]) {
        if (completion) {
            completion (nil);
        }
        return;
    }
    
    NSString* token = [HEMConfig stringForConfig:HEMConfZendeskToken];
    NSString* url = [HEMConfig stringForConfig:HEMConfZendeskURL];
    NSString* clientId = [HEMConfig stringForConfig:HEMConfZendeskClientId];
    
    if (token && url && clientId) {
        ZDKConfig* zendesk = [ZDKConfig instance];
        
        [zendesk initializeWithAppId:token zendeskUrl:url ClientId:clientId onSuccess:^{
            // singleton, no need to weak / strong self
            [self setZendeskIdentity];
            [self configureRequests:^(NSError *requestConfigError) {
                [self setConfigured:YES];
                if (completion) {
                    completion (requestConfigError);
                }
            }];
        } onError:completion];
    }
}

- (void)setCustomFields {
    UIDevice* device = [UIDevice currentDevice];
    NSNumber* osVersionId = @(HEMZendeskCustomFieldIdOSVersion);
    ZDKCustomField* osVersionField = [[ZDKCustomField alloc] initWithFieldId:osVersionId
                                                                    andValue:[device systemVersion]];
    
    NSNumber* deviceModelId = @(HEMZendeskCustomFieldIdDeviceModel);
    NSString* deviceModel = [HEMSupportUtil deviceModel];
    ZDKCustomField* deviceModelField = [[ZDKCustomField alloc] initWithFieldId:deviceModelId
                                                                      andValue:deviceModel];
    
    NSNumber* accountIdFieldId = @(HEMZendeskCustomFieldIdAccountId);
    NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
    ZDKCustomField* accountIdField = [[ZDKCustomField alloc] initWithFieldId:accountIdFieldId
                                                                    andValue:accountId];
    
    [[ZDKConfig instance] setCustomTicketFields:@[osVersionField, deviceModelField, accountIdField]];
}

- (void)setZendeskIdentity {
    void(^setIdentity)(NSString* email, NSString* name) = ^(NSString* email, NSString* name) {
        ZDKAnonymousIdentity* identity = [ZDKAnonymousIdentity new];
        [identity setExternalId:[SENAuthorizationService accountIdOfAuthorizedUser]];
        if (email) {
            [identity setEmail:email];
        }
        if (name) {
            [identity setName:name];
        }
        [[ZDKConfig instance] setUserIdentity:identity];
    };
    
    SENAccount* account = [[SENServiceAccount sharedService] account];
    if (!account) {
        [[SENServiceAccount sharedService] refreshAccount:^(NSError *error) {
            NSString* email = nil;
            NSString* name = nil;
            if (!error) {
                DDLogWarn(@"failed to refresh account");
                SENAccount* account = [[SENServiceAccount sharedService] account];
                email = [account email];
                name = [account name];
            }
            setIdentity(email, name);
        }];
    } else {
        setIdentity([account email], [account name]);
    }

}

- (void)configureRequests:(void(^)(NSError* requestConfigError))completion {
    [ZDKRequests configure:^(ZDKAccount *account, ZDKRequestCreationConfig *requestCreationConfig) {
        [self setCustomFields];
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        [requestCreationConfig setSubject:[NSString stringWithFormat:@"iOS Ticket for Sense %@", appVersion]];
    }];
}

@end

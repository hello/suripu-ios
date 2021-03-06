//
//  HEMZendeskService.m
//  Sense
//
//  Created by Jimmy Lu on 6/4/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAccount.h>
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENService+Protected.h>

#import <ZendeskSDK/ZendeskSDK.h>

#import "UIDevice+HEMUtils.h"
#import "Sense-Swift.h"

#import "HEMZendeskService.h"
#import "HEMSupportUtil.h"
#import "HEMConfig.h"
#import "HEMAccountService.h"

// the following are values found in the Zendesk admin interface that maps
// to the custom fields created
static long const HEMZendeskServiceCustomFieldIdTopic = 24321669;

@interface HEMZendeskService()

@property (nonatomic, assign) BOOL configured;
@property (nonatomic, strong) NSArray* defaultTicketTags;
@property (nonatomic, copy)   NSString* defaultTicketSubject;
@property (nonatomic, copy)   NSString* defaultTicketAdditonalText;

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

#pragma mark - Zendesk methods

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
            [self configureAppearance];
            [self setZendeskIdentity];
            [self configureRequests:^(void) {
                [self setConfigured:YES];
                if (completion) {
                    completion (nil);
                }
            }];
        } onError:completion];
    }
}

- (void)configureAppearance {
    id supportCellAppearance = [ZDKSupportTableViewCell appearance];
    [supportCellAppearance setTitleLabelFont:[UIFont settingsTableCellFont]];
    [supportCellAppearance setTitleLabelColor:[UIColor textColor]];
    [supportCellAppearance setBackgroundColor:[UIColor whiteColor]];
}

- (void)setZendeskIdentity {
    void(^setIdentity)(NSString* email, NSString* name) = ^(NSString* email, NSString* name) {
        ZDKAnonymousIdentity* identity = [ZDKAnonymousIdentity new];
        // do not set the external id using our account id.  Setting external id
        // somehow prevents user from using two different devices for the same
        // Sense account to submit tickets ...
        if (email) {
            [identity setEmail:email];
        }
        if (name) {
            [identity setName:name];
        }
        [[ZDKConfig instance] setUserIdentity:identity];
    };
    
    SENAccount* account = [[HEMAccountService sharedService] account];
    if (!account) {
        [[HEMAccountService sharedService] refresh:^(SENAccount * _Nullable account, NSDictionary<NSNumber *,SENPreference *> * _Nullable preferences) {
            if (account) {
                setIdentity([account email], [account fullName]);
            }
        }];
    } else {
        setIdentity([account email], [account fullName]);
    }

}

- (NSString*)tagMinusZDKTagTokens:(NSString*)tag {
    NSCharacterSet *zdkTagTokens = [NSCharacterSet characterSetWithCharactersInString:@" -,"];
    return [[tag componentsSeparatedByCharactersInSet:zdkTagTokens] componentsJoinedByString:@"_"];
}

- (void)configureRequests:(void(^)(void))completion {
    [ZDKRequests configure:^(ZDKAccount *account, ZDKRequestCreationConfig *requestCreationConfig) {
        // NOTE: Zendesk tags will automatically split words in your strings by spaces and dashes.  Use
        // underscore if multiple words are needed
        SENSenseMetadata* senseMetadata = [[[SENServiceDevice sharedService] devices] senseMetadata];
        NSBundle* bundle = [NSBundle mainBundle];
        UIDevice* device = [UIDevice currentDevice];
        NSString* osVersion = [self tagMinusZDKTagTokens:[device systemVersion]];
        NSString* deviceModel = [self tagMinusZDKTagTokens:[UIDevice currentDeviceModel]];
        NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
        NSString* fwVersion = [senseMetadata  firmwareVersion];
        NSString* appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString* senseId = [senseMetadata uniqueId];

        NSMutableArray* tags = [@[deviceModel, osVersion] mutableCopy];
        if (fwVersion) {
            [tags addObject:fwVersion];
        }
        if (appVersion) {
            [tags addObject:appVersion];
        }
        
        NSMutableString* additionalInfo = [[NSMutableString alloc] initWithString:@"\n\n\n\n-----\n"];
        [additionalInfo appendFormat:@"Id: %@", accountId ?: @""];
        [additionalInfo appendFormat:@"\nSense Id: %@", senseId ?: @""];
        
        [self setDefaultTicketTags:tags];
        [self setDefaultTicketAdditonalText:additionalInfo];
        [self setDefaultTicketSubject:[NSString stringWithFormat:@"iOS Ticket for Sense %@", appVersion]];
        [requestCreationConfig setTags:tags];
        [requestCreationConfig setSubject:[self defaultTicketSubject]];
        [requestCreationConfig setAdditionalRequestInfo:[self defaultTicketAdditonalText]];
        
        if (completion) {
            completion ();
        }
    }];
}

- (void)configureRequestWithTopic:(NSString*)topic completion:(void(^)(void))completion {
    if (!topic) {
        if (completion) {
            completion ();
        }
        return;
    }
    
    [ZDKRequests configure:^(ZDKAccount *account, ZDKRequestCreationConfig *requestCreationConfig) {
        NSNumber* topicId = @(HEMZendeskServiceCustomFieldIdTopic);
        ZDKCustomField* topicField = [[ZDKCustomField alloc] initWithFieldId:topicId andValue:topic];
        [[ZDKConfig instance] setCustomTicketFields:@[topicField]];
        
        // always use the default ticket subject
        [requestCreationConfig setSubject:[self defaultTicketSubject]];
        
        if (completion) {
            completion ();
        }
        
    }];
}

- (void)configureRequestWithSubject:(NSString*)subject completion:(void(^)(void))completion {
    if (!subject) {
        if (completion) {
            completion ();
        }
        return;
    }
    
    [ZDKRequests configure:^(ZDKAccount *account, ZDKRequestCreationConfig *requestCreationConfig) {
        [requestCreationConfig setSubject:subject];
        if (completion) {
            completion ();
        }
        
    }];
}

@end

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
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENDevice.h>

#import <ZendeskSDK/ZendeskSDK.h>
#import <SenseKit/SENService+Protected.h>

#import "HEMZendeskService.h"
#import "HEMSupportUtil.h"
#import "HEMConfig.h"

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

- (NSString*)tagMinusZDKTagTokens:(NSString*)tag {
    NSCharacterSet *zdkTagTokens = [NSCharacterSet characterSetWithCharactersInString:@" -,"];
    return [[tag componentsSeparatedByCharactersInSet:zdkTagTokens] componentsJoinedByString:@"_"];
}

- (void)configureRequests:(void(^)(void))completion {
    [ZDKRequests configure:^(ZDKAccount *account, ZDKRequestCreationConfig *requestCreationConfig) {
        // NOTE: Zendesk tags will automatically split words in your strings by spaces and dashes.  Use
        // underscore if multiple words are needed
        NSBundle* bundle = [NSBundle mainBundle];
        UIDevice* device = [UIDevice currentDevice];
        NSString* osVersion = [self tagMinusZDKTagTokens:[device systemVersion]];
        NSString* deviceModel = [self tagMinusZDKTagTokens:[HEMSupportUtil deviceModel]];
        NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
        NSString* fwVersion = [[[SENServiceDevice sharedService] senseInfo] firmwareVersion];
        NSString* appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString* senseId = [[[SENServiceDevice sharedService] senseInfo] deviceId];

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

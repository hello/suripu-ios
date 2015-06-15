//
//  HEMZendeskService.m
//  Sense
//
//  Created by Jimmy Lu on 6/4/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <ZendeskSDK/ZendeskSDK.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEMZendeskService.h"
#import "HEMSupportUtil.h"
#import "HEMConfig.h"

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
            [self configureRequests:^(NSError *requestConfigError) {
                [self setConfigured:YES];
                if (completion) {
                    completion (requestConfigError);
                }
            }];
        } onError:completion];
    }
}

- (void)configureRequests:(void(^)(NSError* requestConfigError))completion {
    [ZDKRequests configure:^(ZDKAccount *account, ZDKRequestCreationConfig *requestCreationConfig) {
        UIDevice* device = [UIDevice currentDevice];
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
        NSString* appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString* appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString* osVersion = [device systemVersion];
        NSString* deviceModel = [HEMSupportUtil deviceModel];
        
        NSString* format = @"Id: %@\n%@ (%@)\n%@ (%@)";
        NSString* additionalInfo = [NSString stringWithFormat:format,
                                    accountId, appName, appVersion, deviceModel, osVersion];
        
        [requestCreationConfig setAdditionalRequestInfo:additionalInfo];
    }];
}

@end

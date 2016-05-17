//
//  HEMFacebookService.m
//  Sense
//
//  Created by Jimmy Lu on 5/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/Model.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "HEMFacebookService.h"

@implementation HEMFacebookService

- (NSArray<NSString*>*)profilePermissions {
    return @[@"public_profile", @"email"];
}

- (BOOL)hasGrantedProfilePermissions {
    return [FBSDKAccessToken currentAccessToken];
}

- (void)loginFrom:(id)controller completion:(HEMFacebookLoginHandler)completion {
    if ([self hasGrantedProfilePermissions]) {
        completion (NO, nil);
        return;
    }
    
    FBSDKLoginManager *login = [FBSDKLoginManager new];
    [login logInWithReadPermissions:[self profilePermissions]
                 fromViewController:controller
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                    [SENAnalytics trackError:error];
                                }
                                completion ([result isCancelled], error);
                            }];
}

- (void)profileFrom:(id)controller completion:(HEMFacebookProfileHandler)completion {
    [self loginFrom:controller completion:^(BOOL cancelled, NSError * _Nullable error) {
        if (error) {
            [SENAnalytics trackError:error];
            completion (nil, nil, error);
        } else if (!cancelled) {
            NSDictionary* params = @{@"fields" : @"first_name,last_name,email,picture.type(large)"};
            FBSDKGraphRequest* request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                           parameters:params];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                SENAccount* account = nil;
                NSString* photoUrl = nil;
                NSDictionary* dict = SENObjectOfClass(result, [NSDictionary class]);
                if (error) {
                    [SENAnalytics trackError:error];
                } else if (dict) {
                    account = [SENAccount new];
                    [account setEmail:dict[@"email"]];
                    [account setFirstName:dict[@"first_name"]];
                    [account setLastName:dict[@"last_name"]];
                    
                    NSDictionary* pictureDict = SENObjectOfClass(dict[@"picture"], [NSDictionary class]);
                    NSDictionary* dataDict = SENObjectOfClass(pictureDict[@"data"], [NSDictionary class]);
                    if (dataDict) {
                        photoUrl = dataDict[@"url"];
                    }
                }
                completion (account, photoUrl, error);
            }];
        } else { // cancelled
            completion (nil, nil, nil);
        }
    }];
}

- (BOOL)open:(id)app url:(NSURL*)url source:(NSString*)source annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                sourceApplication:source
                                                       annotation:annotation];
}

@end

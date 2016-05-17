//
//  HEMFacebookService.h
//  Sense
//
//  Created by Jimmy Lu on 5/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMFacebookLoginHandler)(BOOL cancelled, NSError* _Nullable error);
typedef void(^HEMFacebookProfileHandler)(SENAccount* _Nullable account, NSString* _Nullable photoURL, NSError* _Nullable error);

@interface HEMFacebookService : SENService

- (BOOL)hasGrantedProfilePermissions;
- (void)loginFrom:(id)controller completion:(HEMFacebookLoginHandler)completion;
- (void)profileFrom:(id)controller completion:(HEMFacebookProfileHandler)completion;
- (BOOL)open:(id)app url:(NSURL*)url source:(NSString*)source annotation:(id)annotation;

@end

NS_ASSUME_NONNULL_END

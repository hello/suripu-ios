//
//  HEMZendeskService.h
//  Sense
//
//  Created by Jimmy Lu on 6/4/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <ZendeskSDK/ZendeskSDK.h>

#import <SenseKit/SENService.h>

@interface HEMZendeskService : SENService

@property (nonatomic, assign, readonly) BOOL configured;

+ (id)sharedService;
- (void)configure:(void(^)(NSError* error))completion;
- (void)configureRequestWithTopic:(NSString*)topic completion:(void(^)(void))completion;

@end

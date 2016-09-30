//
//  HEMExpansionService.h
//  Sense
//
//  Created by Jimmy Lu on 9/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SenseKit.h>

@class SENExpansion;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMExpansionListHandler)(NSArray<SENExpansion*>* _Nullable expansions, NSError* _Nullable error);
typedef void(^HEMExpansionHandler)(SENExpansion* _Nullable expansion, NSError* _Nullable error);
typedef void(^HEMExpansionConfigHandler)(NSArray<SENExpansionConfig*>* _Nullable configs, NSError* _Nullable error);
typedef void(^HEMExpansionUpdateHandler)(NSError* _Nullable error);

@interface HEMExpansionService : SENService

@property (nonatomic, strong, readonly) NSArray<SENExpansion*>* expansions;

- (BOOL)isEnabledForHardware:(SENSenseHardware)hardware;
- (BOOL)isConnected:(SENExpansion*)expansion;
- (BOOL)hasExpansion:(SENExpansion*)expansion connectedWithURL:(NSURL*)url;
- (void)getListOfExpansion:(HEMExpansionListHandler)completion;
- (void)getConfigurationsForExpansion:(SENExpansion*)expansion completion:(HEMExpansionConfigHandler)completion;
- (void)enable:(BOOL)enable expansion:(SENExpansion*)expansion completion:(HEMExpansionUpdateHandler)completion;
- (void)removeExpansion:(SENExpansion*)expansion completion:(HEMExpansionUpdateHandler)completion;
- (void)setConfiguration:(SENExpansionConfig*)config
            forExpansion:(SENExpansion*)expansion
              completion:(HEMExpansionHandler)completion;
- (void)refreshExpansion:(SENExpansion*)expansion completion:(HEMExpansionHandler)completion;
- (NSURLRequest*)authorizationRequestForExpansion:(SENExpansion*)expansion;

@end

NS_ASSUME_NONNULL_END
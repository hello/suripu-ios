//
//  SENAPIAccount+Private.h
//  Pods
//
//  Created by Jimmy Lu on 9/5/14.
//
//

#import "SENAPIAccount.h"

@class SENAccount;

@interface SENAPIAccount (Private)

+ (SENAccount*)accountFromResponse:(id)responseObject;
+ (NSDictionary*)dictionaryValue:(SENAccount*)account;

@end

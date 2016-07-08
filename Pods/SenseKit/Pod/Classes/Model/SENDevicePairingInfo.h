//
//  SENDevicePairingInfo.h
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import <Foundation/Foundation.h>

@interface SENDevicePairingInfo : NSObject

@property (nonatomic, copy,   readonly, nullable) NSString* senseId;
@property (nonatomic, strong, readonly, nullable) NSNumber* pairedAccounts;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary*)dict;

@end

//
//  SENDeviceMetadata.h
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import <Foundation/Foundation.h>

@interface SENDeviceMetadata : NSObject

@property (nonatomic, copy, readonly, nullable) NSString* uniqueId;
@property (nonatomic, copy, readonly, nullable) NSString* firmwareVersion;
@property (nonatomic, strong, readonly, nullable) NSDate* lastSeenDate;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary*)dict;
- (nonnull NSDictionary*)dictionaryValue;

@end

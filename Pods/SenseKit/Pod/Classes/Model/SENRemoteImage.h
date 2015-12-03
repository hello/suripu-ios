//
//  SENRemoteImage.h
//  Pods
//
//  Created by Jimmy Lu on 12/2/15.
//
//

#import <Foundation/Foundation.h>

@interface SENRemoteImage : NSObject <NSCoding>

@property (nullable, nonatomic, copy, readonly) NSString* normalUri;
@property (nullable, nonatomic, copy, readonly) NSString* doubleScaleUri;
@property (nullable, nonatomic, copy, readonly) NSString* tripeScaleUri;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary*)dictionary;
- (nonnull instancetype)init NS_UNAVAILABLE;

@end

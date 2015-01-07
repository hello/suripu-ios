//
//  SENSound.h
//  Pods
//
//  Created by Delisa Mason on 1/6/15.
//
//

#import <Foundation/Foundation.h>

@interface SENSound : NSObject <NSCoding>

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, strong, readonly) NSString* displayName;
@property (nonatomic, strong, readonly) NSString* URLPath;
@property (nonatomic, strong, readonly) NSString* identifier;
@end

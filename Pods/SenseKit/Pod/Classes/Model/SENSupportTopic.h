//
//  SENSupportTopic.h
//  Pods
//
//  Created by Jimmy Lu on 6/25/15.
//
//

#import <Foundation/Foundation.h>

@interface SENSupportTopic : NSObject

@property (nonatomic, copy, readonly) NSString* topic;
@property (nonatomic, copy, readonly) NSString* displayName;

- (instancetype)initWithRawResponse:(NSDictionary*)response;
- (instancetype)initWithTopic:(NSString*)topic displayName:(NSString*)name;

@end

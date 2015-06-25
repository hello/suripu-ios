//
//  SENSupportTopic.m
//  Pods
//
//  Created by Jimmy Lu on 6/25/15.
//
//

#import "SENSupportTopic.h"

static NSString* const SENSupportTopicRespKeyTopic = @"topic";
static NSString* const SENSupportTopicRespKeyName = @"display_name";

@interface SENSupportTopic()

@property (nonatomic, copy) NSString* topic;
@property (nonatomic, copy) NSString* displayName;

@end

@implementation SENSupportTopic

- (instancetype)initWithRawResponse:(NSDictionary*)response {
    self = [super init];
    if (self) {
        [self processResponse:response];
    }
    return self;
}

- (instancetype)initWithTopic:(NSString*)topic displayName:(NSString*)name {
    self = [super init];
    if (self) {
        _topic = topic;
        _displayName = name;
    }
    return self;
}

- (void)processResponse:(NSDictionary*)response {
    id topicObject = response[SENSupportTopicRespKeyTopic];
    if ([topicObject isKindOfClass:[NSString class]]) {
        [self setTopic:topicObject];
    }
    
    id nameObject = response[SENSupportTopicRespKeyName];
    if ([nameObject isKindOfClass:[NSString class]]) {
        [self setDisplayName:nameObject];
    }
}

@end

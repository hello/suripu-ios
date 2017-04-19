//
//  SENVoiceCommandGroup.m
//  Pods
//
//  Created by Jimmy Lu on 4/19/17.
//
//
#import "Model.h"
#import "SENVoiceCommandGroup.h"

@implementation SENVoiceCommandSubGroup

static NSString* const kParamTitle = @"command_title";
static NSString* const kParamCommands = @"commands";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        _localizedTitle = [SENObjectOfClass(data[kParamTitle], [NSString class]) copy];
        _commands = [SENObjectOfClass(data[kParamCommands], [NSArray class]) copy];
    }
    return self;
}

@end

@implementation SENVoiceCommandGroup

static NSString* const kParamGroupTitle = @"title";
static NSString* const kParamExample = @"description";
static NSString* const kParamSubGroups = @"subtopics";
static NSString* const kParamImage = @"icon_urls";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary* imageDict = SENObjectOfClass(data[kParamImage], [NSDictionary class]);
        NSArray* groupObjects = SENObjectOfClass(data[kParamSubGroups], [NSArray class]);
        NSMutableArray* groups = [NSMutableArray arrayWithCapacity:[groupObjects count]];
        for (id groupObj in groupObjects) {
            NSDictionary* groupDict = SENObjectOfClass(groupObj, [NSDictionary class]);
            if (groupDict) {
                [groups addObject:[[SENVoiceCommandSubGroup alloc] initWithDictionary:groupDict]];
            }
        }
        
        _localizedTitle = [SENObjectOfClass(data[kParamGroupTitle], [NSString class]) copy];
        _localizedExample = [SENObjectOfClass(data[kParamExample], [NSString class]) copy];
        _iconImage = [[SENRemoteImage alloc] initWithDictionary:imageDict];
        _groups = groups;
    }
    return self;
}

@end

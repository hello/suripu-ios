//
//  SENAppUnreadStats.m
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import "SENAppUnreadStats.h"
#import "Model.h"

static NSString* const SENAppUnreadStatsInsights = @"has_unread_insights";
static NSString* const SENAppUnreadStatsQuestions = @"has_unanswered_questions";

@interface SENAppUnreadStats()

@property (nonatomic, assign, getter=hasUnreadInsights) BOOL unreadInsights;
@property (nonatomic, assign, getter=hasUnreadQuestions) BOOL unreadQuestions;

@end

@implementation SENAppUnreadStats

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _unreadInsights = SENBoolValue(dictionary[SENAppUnreadStatsInsights]);
        _unreadQuestions = SENBoolValue(dictionary[SENAppUnreadStatsQuestions]);
    }
    return self;
}

- (NSDictionary*)dictionaryValue {
    return @{SENAppUnreadStatsInsights : @([self hasUnreadInsights]),
             SENAppUnreadStatsQuestions : @([self hasUnreadQuestions])};
}

@end


#import "SENInsight.h"

NSString* const SENInsightDateCreatedKey = @"created_utc";
NSString* const SENInsightTitleKey = @"title";
NSString* const SENInsightMessageKey = @"message";

@implementation SENInsight

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _title = dict[SENInsightTitleKey];
        _message = dict[SENInsightMessageKey];
        _dateCreated = [self dateFromNumber:dict[SENInsightDateCreatedKey]];
    }
    return self;
}

- (NSDate*)dateFromNumber:(id)number {
    if (number == nil || ![number isKindOfClass:[NSNumber class]]) return nil;
    return [NSDate dateWithTimeIntervalSince1970:[number longLongValue] / 1000];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectForKey:SENInsightTitleKey];
        _message = [aDecoder decodeObjectForKey:SENInsightMessageKey];
        _dateCreated = [aDecoder decodeObjectForKey:SENInsightDateCreatedKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:SENInsightTitleKey];
    [aCoder encodeObject:self.message forKey:SENInsightMessageKey];
    [aCoder encodeObject:self.dateCreated forKey:SENInsightDateCreatedKey];
}

@end

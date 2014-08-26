
#import "SENInsight.h"

NSString* const SENInsightDateCreatedKey = @"date_created";
NSString* const SENInsightTypeKey = @"type";
NSString* const SENInsightMessageKey = @"message";

@implementation SENInsight

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _type = dict[SENInsightTypeKey];
        _message = dict[SENInsightMessageKey];
        _dateCreated = dict[SENInsightDateCreatedKey];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _type = [aDecoder decodeObjectForKey:SENInsightTypeKey];
        _message = [aDecoder decodeObjectForKey:SENInsightMessageKey];
        _dateCreated = [aDecoder decodeObjectForKey:SENInsightDateCreatedKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.type forKey:SENInsightTypeKey];
    [aCoder encodeObject:self.message forKey:SENInsightMessageKey];
    [aCoder encodeObject:self.dateCreated forKey:SENInsightDateCreatedKey];
}

@end

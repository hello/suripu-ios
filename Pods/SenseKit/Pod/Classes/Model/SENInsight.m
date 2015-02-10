
#import "SENInsight.h"

// insight constants
static NSString* const SENInsightDateCreatedKey = @"timestamp";
static NSString* const SENInsightTitleKey = @"title";
static NSString* const SENInsightMessageKey = @"message";
static NSString* const SENInsightCategory = @"category";
static NSString* const SENInsightId = @"identifier";
static NSString* const SENInsightText = @"text";
static NSString* const SENInsightImageUri = @"image_url";

static NSString* const SENInsightCategoryGeneric = @"GENERIC";

@implementation SENInsight

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _title = dict[SENInsightTitleKey];
        _message = dict[SENInsightMessageKey];
        _dateCreated = [self dateFromNumber:dict[SENInsightDateCreatedKey]];
        _category = dict[SENInsightCategory];
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
        _category = [aDecoder decodeObjectForKey:SENInsightCategory];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:SENInsightTitleKey];
    [aCoder encodeObject:self.message forKey:SENInsightMessageKey];
    [aCoder encodeObject:self.dateCreated forKey:SENInsightDateCreatedKey];
    [aCoder encodeObject:self.category forKey:SENInsightCategory];
}

- (BOOL)isGeneric {
    return [[self category] isEqualToString:SENInsightCategoryGeneric];
}

- (BOOL)isEqual:(SENInsight*)other
{
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[SENInsight class]]) {
        return NO;
    } else {
        return ((self.title && [self.title isEqualToString:other.title]) || (!self.title && !other.title))
            && ((self.message && [self.message isEqualToString:other.message]) || (!self.message && !other.message))
            && ((self.dateCreated && [self.dateCreated isEqualToDate:other.dateCreated]) || (!self.dateCreated && !other.dateCreated))
            && ((self.category && [self.category isEqualToString:other.category]) || (!self.category && !other.category));
    }
}

- (NSUInteger)hash
{
    return [self.title hash] + [self.message hash] + [self.dateCreated hash] + [self.category hash];
}

@end

#pragma mark - Insight Info

@interface SENInsightInfo()

@property (nonatomic, assign, readwrite) NSUInteger identifier;
@property (nonatomic, copy, readwrite)   NSString* category;
@property (nonatomic, copy, readwrite)   NSString* title;
@property (nonatomic, copy, readwrite)   NSString* info;
@property (nonatomic, copy, readwrite)   NSString* imageURI;

@end

@implementation SENInsightInfo

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        id identifierObj = dict[SENInsightId];
        _identifier = [identifierObj isKindOfClass:[NSNumber class]] ? [identifierObj integerValue] : NSNotFound;
        _category = dict[SENInsightCategory];
        _info = dict[SENInsightText];
        _imageURI = dict[SENInsightImageUri];
        _title = dict[SENInsightTitleKey];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _identifier = [[aDecoder decodeObjectForKey:SENInsightId] unsignedIntegerValue];
        _category = [aDecoder decodeObjectForKey:SENInsightCategory];
        _info = [aDecoder decodeObjectForKey:SENInsightText];
        _imageURI = [aDecoder decodeObjectForKey:SENInsightImageUri];
        _title = [aDecoder decodeObjectForKey:SENInsightTitleKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.identifier) forKey:SENInsightId];
    [aCoder encodeObject:self.category forKey:SENInsightCategory];
    [aCoder encodeObject:self.info forKey:SENInsightText];
    [aCoder encodeObject:self.imageURI forKey:SENInsightImageUri];
    [aCoder encodeObject:self.title forKey:SENInsightTitleKey];
}

- (BOOL)isEqual:(SENInsightInfo*)other
{
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[SENInsightInfo class]]) {
        return NO;
    } else {
        return ((self.category && [self.category isEqualToString:other.category]) || (!self.category && !other.category))
            && ((self.info && [self.info isEqualToString:other.info]) || (!self.info && !other.info))
            && ((self.imageURI && [self.imageURI isEqualToString:other.imageURI]) || (!self.imageURI && !other.imageURI))
            && ((self.title && [self.title isEqualToString:other.title]) || (!self.title && !other.title))
            && ((self.category && [self.category isEqualToString:other.category]) || (!self.category && !other.category));
    }
}

- (NSUInteger)hash
{
    return self.identifier + [self.title hash] + [self.info hash];
}

@end

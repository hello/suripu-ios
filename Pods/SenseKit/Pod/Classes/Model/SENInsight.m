
#import "SENInsight.h"
#import "Model.h"

// insight constants
static NSString* const SENInsightShareType = @"insight";
static NSString* const SENInsightDateCreatedKey = @"timestamp";
static NSString* const SENInsightTitleKey = @"title";
static NSString* const SENInsightMessageKey = @"message";
static NSString* const SENInsightCategory = @"category";
static NSString* const SENInsightId = @"id";
static NSString* const SENInsightInfoId = @"identifier";
static NSString* const SENInsightText = @"text";
static NSString* const SENInsightImageUri = @"image_url";
static NSString* const SENInsightInfoPreviewKey = @"info_preview";
static NSString* const SENInsightMultiDensityImage = @"image";
static NSString* const SENInsightCategoryName = @"category_name";
static NSString* const SENInsightParamType = @"insight_type";
static NSString* const SENInsightTypeValueDefault = @"DEFAULT";
static NSString* const SENInsightTypeValueBasic = @"BASIC";

@implementation SENInsight

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _title = [dict[SENInsightTitleKey] copy];
        _message = [dict[SENInsightMessageKey] copy];
        _category = [dict[SENInsightCategory] copy];
        _infoPreview = [dict[SENInsightInfoPreviewKey] copy];
        _categoryName = [dict[SENInsightCategoryName] copy];
        _type = [self typeFromString:dict[SENInsightParamType]];
        _identifier = [dict[SENInsightId] copy];
        
        NSNumber* dateMillis = SENObjectOfClass(dict[SENInsightDateCreatedKey], [NSNumber class]);
        if (dateMillis) {
            _dateCreated = SENDateFromNumber(dateMillis);
        }
        
        NSDictionary* imageDict = SENObjectOfClass(dict[SENInsightMultiDensityImage], [NSDictionary class]);
        if (imageDict) {
            _remoteImage = [[SENRemoteImage alloc] initWithDictionary:imageDict];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _title = [aDecoder decodeObjectForKey:SENInsightTitleKey];
        _message = [aDecoder decodeObjectForKey:SENInsightMessageKey];
        _dateCreated = [aDecoder decodeObjectForKey:SENInsightDateCreatedKey];
        _category = [aDecoder decodeObjectForKey:SENInsightCategory];
        _infoPreview = [aDecoder decodeObjectForKey:SENInsightInfoPreviewKey];
        _remoteImage = [aDecoder decodeObjectForKey:SENInsightMultiDensityImage];
        _categoryName = [aDecoder decodeObjectForKey:SENInsightCategoryName];
        _type = [self typeFromString:[aDecoder decodeObjectForKey:SENInsightParamType]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (self.title) [aCoder encodeObject:self.title forKey:SENInsightTitleKey];
    if (self.message) [aCoder encodeObject:self.message forKey:SENInsightMessageKey];
    if (self.dateCreated) [aCoder encodeObject:self.dateCreated forKey:SENInsightDateCreatedKey];
    if (self.category) [aCoder encodeObject:self.category forKey:SENInsightCategory];
    if (self.infoPreview) [aCoder encodeObject:self.infoPreview forKey:SENInsightInfoPreviewKey];
    if (self.remoteImage) [aCoder encodeObject:self.remoteImage forKey:SENInsightMultiDensityImage];
    if (self.categoryName) [aCoder encodeObject:self.categoryName forKey:SENInsightCategoryName];
    [aCoder encodeObject:[self rawTypeFromEnum:self.type] forKey:SENInsightParamType];
}

- (BOOL)isEqual:(SENInsight*)other {
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[SENInsight class]]) {
        return NO;
    } else {
        return ([self.title isEqualToString:other.title] || (!self.title && !other.title))
            && ([self.message isEqualToString:other.message] || (!self.message && !other.message))
            && ([self.dateCreated isEqualToDate:other.dateCreated] || (!self.dateCreated && !other.dateCreated))
            && ([self.infoPreview isEqualToString:other.infoPreview] || (!self.infoPreview && !other.infoPreview))
            && ([self.category isEqualToString:other.category] || (!self.category && !other.category))
            && ([self.remoteImage isEqual:other.remoteImage] || (!self.remoteImage && !other.remoteImage))
            && ([self.categoryName isEqual:other.categoryName] || (!self.categoryName && !other.categoryName))
            && (self.type == other.type);
    }
}

- (NSUInteger)hash {
    return [self.title hash] + [self.message hash] + [self.dateCreated hash] + [self.category hash] + [self.infoPreview hash] + [self.remoteImage hash] + [self.categoryName hash] + self.type;
}

- (SENInsightType)typeFromString:(NSString*)rawType {
    NSString* rawTypeUpper = [rawType uppercaseString];
    SENInsightType type = SENInsightTypeDefault;
    if ([rawTypeUpper isEqualToString:SENInsightTypeValueBasic]) {
        type = SENInsightTypeBasic;
    }
    return type;
}

- (NSString*)rawTypeFromEnum:(SENInsightType)type {
    switch (type) {
        case SENInsightTypeBasic:
            return SENInsightTypeValueBasic;
        case SENInsightTypeDefault:
        default:
            return SENInsightTypeValueDefault;
    }
}

- (NSString*)shareType {
    return SENInsightShareType;
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
        id identifierObj = dict[SENInsightInfoId];
        _identifier = [identifierObj isKindOfClass:[NSNumber class]] ? [identifierObj integerValue] : NSNotFound;
        _category = [dict[SENInsightCategory] copy];
        _info = [dict[SENInsightText] copy];
        _imageURI = [dict[SENInsightImageUri] copy];
        _title = [dict[SENInsightTitleKey] copy];
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

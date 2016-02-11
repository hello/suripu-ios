//
//  SENTrendsGraph.m
//  Pods
//
//  Created by Jimmy Lu on 1/28/16.
//
//
#import "Model.h"
#import "SENTrendsGraph.h"
#import "SENConditionRange.h"

static NSString* const SENTrendsGraphSectionValues = @"values";
static NSString* const SENTrendsGraphSectionTitles = @"titles";
static NSString* const SENTrendsGraphSectionHighlightedValues = @"highlighted_values";
static NSString* const SENTrendsGraphSectionHighlightedTitle = @"highlighted_title";
static NSString* const SENTrendsGraphTitle = @"title";
static NSString* const SENTrendsGraphValue = @"value";
static NSString* const SENTrendsGraphDataType = @"data_type";
static NSString* const SENTrendsGraphDataTypeScore = @"SCORES";
static NSString* const SENTrendsGraphDataTypeHour = @"HOURS";
static NSString* const SENTrendsGraphDataTypePercent = @"PERCENTS";
static NSString* const SENTrendsGraphCondition = @"condition";
static NSString* const SENTrendsGraphDisplayType = @"graph_type";
static NSString* const SENTrendsGraphDisplayTypeGrid = @"GRID";
static NSString* const SENTrendsGraphDisplayTypeOverview = @"OVERVIEW";
static NSString* const SENTrendsGraphDisplayTypeBar = @"BAR";
static NSString* const SENTrendsGraphDisplayTypeBubble = @"BUBBLES";
static NSString* const SENTrendsGraphTimeScale = @"time_scale";
static NSString* const SENTrendsGraphTimeScaleWeek = @"LAST_WEEK";
static NSString* const SENTrendsGraphTimeScaleMonth = @"LAST_MONTH";
static NSString* const SENTrendsGraphTimeScaleQuarter = @"LAST_3_MONTHS";
static NSString* const SENTrendsGraphMinValue = @"min_value";
static NSString* const SENTrendsGraphMaxValue = @"max_value";
static NSString* const SENTrendsGraphSections = @"sections";
static NSString* const SENTrendsGraphConditionRanges = @"condition_ranges";
static NSString* const SENTrendsGraphAnnotations = @"annotations";

SENTrendsDataType SENTrendsDataTypeFromString(id dataType) {
    SENTrendsDataType type = SENTrendsDataTypeUnknown;
    if ([dataType isKindOfClass:[NSString class]]) {
        if ([dataType isEqualToString:SENTrendsGraphDataTypeScore]) {
            type = SENTrendsDataTypeScore;
        } else if ([dataType isEqualToString:SENTrendsGraphDataTypeHour]) {
            type = SENTrendsDataTypeHour;
        } else if ([dataType isEqualToString:SENTrendsGraphDataTypePercent]) {
            type = SENTrendsDataTypePercent;
        }
    }
    return type;
}

SENTrendsTimeScale SENTrendsTimeScaleFromString(id timeScale) {
    SENTrendsTimeScale time = SENTrendsTimeScaleUnknown;
    if ([timeScale isKindOfClass:[NSString class]]) {
        NSString* uppercase = [timeScale uppercaseString];
        if ([uppercase isEqualToString:SENTrendsGraphTimeScaleWeek]) {
            time = SENTrendsTimeScaleWeek;
        } else if ([uppercase isEqualToString:SENTrendsGraphTimeScaleMonth]) {
            time = SENTrendsTimeScaleMonth;
        } else if ([uppercase isEqualToString:SENTrendsGraphTimeScaleQuarter]) {
            time = SENTrendsTimeScaleQuarter;
        }
    }
    return time;
}

NSString* SENTrendsTimeScaleValueFromEnum(SENTrendsTimeScale timeScale) {
    switch (timeScale) {
        case SENTrendsTimeScaleWeek:
            return SENTrendsGraphTimeScaleWeek;
        case SENTrendsTimeScaleMonth:
            return SENTrendsGraphTimeScaleMonth;
        case SENTrendsTimeScaleQuarter:
            return SENTrendsGraphTimeScaleQuarter;
        default:
            return @"UNDEFINED";
    }
}

@interface SENTrendsGraphSection()

@property (nonatomic, strong) NSArray<NSNumber*>* values;
@property (nonatomic, strong) NSArray<NSString*>* titles;
@property (nonatomic, strong) NSArray<NSNumber*>* highlightedValues;
@property (nonatomic, strong) NSArray<NSString*>* highlightedTitles;

@end

@implementation SENTrendsGraphSection

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _values = SENObjectOfClass(dictionary[SENTrendsGraphSectionValues], [NSArray class]);
        _titles = SENObjectOfClass(dictionary[SENTrendsGraphSectionTitles], [NSArray class]);
        _highlightedValues = SENObjectOfClass(dictionary[SENTrendsGraphSectionHighlightedValues], [NSArray class]);
        _highlightedTitles = SENObjectOfClass(dictionary[SENTrendsGraphSectionHighlightedTitle], [NSArray class]);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SENTrendsGraphSection class]]) {
        return NO;
    }
    
    SENTrendsGraphSection* other = object;
    return ((![self values] && ![other values]) || [[self values] isEqual:[other values]])
    && ((![self titles] && ![other titles]) || [[self titles] isEqual:[other titles]])
    && ((![self highlightedValues] && ![other highlightedValues]) || [[self highlightedValues] isEqual:[other highlightedValues]])
    && ((![self highlightedTitles] && ![other highlightedTitles]) || [[self highlightedTitles] isEqual:[other highlightedTitles]]);
}

- (NSUInteger)hash {
    NSUInteger const prime = 7;
    NSUInteger result = prime + [[self values] hash];
    result = prime * result + [[self titles] hash];
    result = prime * result + [[self highlightedValues] hash];
    result = prime * result + [[self highlightedTitles] hash];
    return result;
}

@end

@interface SENTrendsAnnotation()

@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) NSNumber* value;
@property (nonatomic, assign) SENTrendsDataType dataType;
@property (nonatomic, assign) SENCondition condition;

@end

@implementation SENTrendsAnnotation

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _title = SENObjectOfClass(dictionary[SENTrendsGraphTitle], [NSString class]);
        _value = SENObjectOfClass(dictionary[SENTrendsGraphValue], [NSNumber class]);
        _dataType = SENTrendsDataTypeFromString(dictionary[SENTrendsGraphDataType]);
        _condition = SENConditionFromString(dictionary[SENTrendsGraphCondition]);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SENTrendsAnnotation class]]) {
        return NO;
    }
    
    SENTrendsAnnotation* other = object;
    return ((![self title] && ![other title]) || [[self title] isEqualToString:[other title]])
        && ((![self value] && ![other value]) || [[self value] isEqual:[other value]])
        && [self dataType] == [other dataType]
        && [self condition] == [other condition];
}

- (NSUInteger)hash {
    NSUInteger const prime = 11;
    NSUInteger result = prime + [[self title] hash];
    result = prime * result + [[self value] hash];
    result = prime * result + [self dataType];
    result = prime * result + [self condition];
    return result;
}

@end

@interface SENTrendsGraph()

@property (nonatomic, assign) SENTrendsTimeScale timeScale;
@property (nonatomic, assign) SENTrendsDataType dataType;
@property (nonatomic, assign) SENTrendsDisplayType displayType;
@property (nonatomic, copy)   NSString* title;
@property (nonatomic, strong) NSNumber* minValue;
@property (nonatomic, strong) NSNumber* maxValue;
@property (nonatomic, strong) NSArray<SENConditionRange*>* conditionRanges;
@property (nonatomic, strong) NSArray<SENTrendsGraphSection*>* sections;
@property (nonatomic, strong) NSArray<SENTrendsAnnotation*>* annotations;

@end

@implementation SENTrendsGraph

SENTrendsDisplayType SENTrendsDisplayTypeFromString(id displayType) {
    SENTrendsDisplayType type = SENTrendsDisplayTypeUnknown;
    if ([displayType isKindOfClass:[NSString class]]) {
        if ([displayType isEqualToString:SENTrendsGraphDisplayTypeGrid]) {
            type = SENTrendsDisplayTypeGrid;
        } else if ([displayType isEqualToString:SENTrendsGraphDisplayTypeOverview]) {
            type = SENTrendsDisplayTypeOverview;
        } else if ([displayType isEqualToString:SENTrendsGraphDisplayTypeBar]) {
            type = SENTrendsDisplayTypeBar;
        } else if ([displayType isEqualToString:SENTrendsGraphDisplayTypeBubble]) {
            type = SENTrendsDisplayTypeBubble;
        }
    }
    return type;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _timeScale = SENTrendsTimeScaleFromString(dictionary[SENTrendsGraphTimeScale]);
        _dataType = SENTrendsDataTypeFromString(dictionary[SENTrendsGraphDataType]);
        _displayType = SENTrendsDisplayTypeFromString(dictionary[SENTrendsGraphDisplayType]);
        _title = SENObjectOfClass(dictionary[SENTrendsGraphTitle], [NSString class]);
        _minValue = SENObjectOfClass(dictionary[SENTrendsGraphMinValue], [NSNumber class]);
        _maxValue = SENObjectOfClass(dictionary[SENTrendsGraphMaxValue], [NSNumber class]);
        
        NSArray* rawSections = SENObjectOfClass(dictionary[SENTrendsGraphSections], [NSArray class]);
        _sections = [self sectionsFromRawValues:rawSections];
        
        NSArray* rawRanges = SENObjectOfClass(dictionary[SENTrendsGraphConditionRanges], [NSArray class]);
        _conditionRanges = [self conditionRangesFromRawValues:rawRanges];
        
        NSArray* rawAnnotations = SENObjectOfClass(dictionary[SENTrendsGraphAnnotations], [NSArray class]);
        _annotations = [self annotationsFromRawValues:rawAnnotations];
    }
    return self;
}

- (NSArray*)sectionsFromRawValues:(NSArray*)rawSections {
    NSMutableArray*  sections = [NSMutableArray arrayWithCapacity:[rawSections count]];
    for (id rawSection in rawSections) {
        if ([rawSection isKindOfClass:[NSDictionary class]]) {
            [sections addObject:[[SENTrendsGraphSection alloc] initWithDictionary:rawSection]];
        }
    }
    return sections;
}

- (NSArray*)conditionRangesFromRawValues:(NSArray*)rawRanges {
    NSMutableArray*  ranges = [NSMutableArray arrayWithCapacity:[rawRanges count]];
    for (id rawRange in rawRanges) {
        if ([rawRange isKindOfClass:[NSDictionary class]]) {
            [ranges addObject:[[SENConditionRange alloc] initWithDictionary:rawRange]];
        }
    }
    return ranges;
}

- (NSArray*)annotationsFromRawValues:(NSArray*)rawAnnotations {
    NSMutableArray*  annotations = [NSMutableArray arrayWithCapacity:[rawAnnotations count]];
    for (id rawAnnotation in rawAnnotations) {
        if ([rawAnnotation isKindOfClass:[NSDictionary class]]) {
            [annotations addObject:[[SENTrendsAnnotation alloc] initWithDictionary:rawAnnotation]];
        }
    }
    return annotations;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SENTrendsGraph class]]) {
        return NO;
    }
    
    SENTrendsGraph* other = object;
    return [self timeScale] == [other timeScale]
        && [self dataType] == [other dataType]
        && [self displayType] == [other displayType]
        && ((![self title] && ![other title]) || [[self title] isEqualToString:[other title]])
        && ((![self minValue] && ![other minValue]) || [[self minValue] isEqual:[other minValue]])
        && ((![self maxValue] && ![other maxValue]) || [[self maxValue] isEqual:[other maxValue]])
        && ((![self sections] && ![other sections]) || [[self sections] isEqual:[other sections]])
        && ((![self conditionRanges] && ![other conditionRanges]) || [[self conditionRanges] isEqual:[other conditionRanges]])
        && ((![self annotations] && ![other annotations]) || [[self annotations] isEqual:[other annotations]]);
}

- (NSUInteger)hash {
    NSUInteger const prime = 23;
    NSUInteger result = prime + [self timeScale];
    result = prime * result + [self dataType];
    result = prime * result + [self displayType];
    result = prime * result + [[self title] hash];
    result = prime * result + [[self minValue] hash];
    result = prime * result + [[self maxValue] hash];
    result = prime * result + [[self sections] hash];
    result = prime * result + [[self conditionRanges] hash];
    result = prime * result + [[self annotations] hash];
    return result;
}

@end

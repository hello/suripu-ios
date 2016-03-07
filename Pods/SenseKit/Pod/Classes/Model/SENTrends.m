//
//  SENTrends.m
//  Pods
//
//  Created by Jimmy Lu on 1/28/16.
//
//
#import "Model.h"
#import "SENTrends.h"
#import "SENTrendsGraph.h"

static NSString* const SENTrendsAvaiableTimeScales = @"available_time_scales";
static NSString* const SENTrendsGraphs = @"graphs";

@interface SENTrends()

@property (nonatomic, strong) NSArray<NSNumber*>* availableTimeScales;
@property (nonatomic, strong) NSArray<SENTrendsGraph*>* graphs;

@end

@implementation SENTrends

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        NSArray* rawTimeScales = SENObjectOfClass(dictionary[SENTrendsAvaiableTimeScales], [NSArray class]);
        _availableTimeScales = [self timeScalesFromRawValues:rawTimeScales];
        
        NSArray* rawGraphs = SENObjectOfClass(dictionary[SENTrendsGraphs], [NSArray class]);
        _graphs = [self graphsFromRawGraphs:rawGraphs];
    }
    return self;
}

- (NSArray<SENTrendsGraph*>*)graphsFromRawGraphs:(NSArray<NSDictionary*>*)rawGraphs {
    NSMutableArray<SENTrendsGraph*>* graphs = [NSMutableArray arrayWithCapacity:[rawGraphs count]];
    for (id rawGraph in rawGraphs) {
        if ([rawGraph isKindOfClass:[NSDictionary class]]) {
            [graphs addObject:[[SENTrendsGraph alloc] initWithDictionary:rawGraph]];
        }
    }
    return graphs;
}

- (NSArray<NSNumber*>*)timeScalesFromRawValues:(NSArray<NSString*>*)rawValues {
    NSMutableArray<NSNumber*>* timeScales = [NSMutableArray arrayWithCapacity:[rawValues count]];
    for (id timeScale in rawValues) {
        if ([timeScale isKindOfClass:[NSString class]]) {
            [timeScales addObject:@(SENTrendsTimeScaleFromString(timeScale))];
        }
    }
    return timeScales;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SENTrends class]]) {
        return NO;
    }
    
    SENTrends* other = object;
    return ((![self availableTimeScales] && ![other availableTimeScales]) && [[self availableTimeScales] isEqual:[other availableTimeScales]])
        && ((![self graphs] && ![other graphs]) && [[self graphs] isEqual:[other graphs]]);
}

- (NSUInteger)hash {
    NSUInteger const prime = 2;
    NSUInteger result = prime + [[self availableTimeScales] hash];
    result = prime * result + [[self graphs] hash];
    return result;
}

@end

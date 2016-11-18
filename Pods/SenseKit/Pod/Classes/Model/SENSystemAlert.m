//
//  SENSystemAlert.m
//  Pods
//
//  Created by Jimmy Lu on 11/8/16.
//
//

#import "SENSystemAlert.h"
#import "Model.h"

static NSString* const kSENSystemAlertKeyTitle = @"title";
static NSString* const kSENSystemAlertKeyBody = @"body";
static NSString* const kSENSystemAlertKeyCategory = @"category";
static NSString* const kSENSystemAlertCategoryExpansionUnreachable = @"EXPANSION_UNREACHABLE";

@implementation SENSystemAlert

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        _localizedTitle = SENObjectOfClass(data[kSENSystemAlertKeyTitle],
                                           [NSString class]);
        _localizedBody = SENObjectOfClass(data[kSENSystemAlertKeyBody],
                                          [NSString class]);
        
        NSString* categoryString = SENObjectOfClass(data[kSENSystemAlertKeyCategory],
                                                    [NSString class]);
        _category = [self categoryFromString:categoryString];
    }
    return self;
}

- (SENAlertCategory)categoryFromString:(NSString*)categoryString {
    NSString* upper = [categoryString uppercaseString];
    if ([upper isEqualToString:kSENSystemAlertCategoryExpansionUnreachable]) {
        return SENAlertCategoryExpansionUnreachable;
    } else {
        return SENAlertCategoryUnknown;
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SENSystemAlert* other = object;
    return SENObjectIsEqual([self localizedTitle], [other localizedTitle])
        && SENObjectIsEqual([self localizedBody], [other localizedBody])
        && [self category] == [other category];
}

- (NSUInteger)hash {
    NSUInteger const prime = 2;
    NSUInteger result = prime + [[self localizedTitle] hash];
    result = prime * result + [[self localizedBody] hash];
    result = prime * result + [self category];
    return result;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@ @title=%@ body=%@>",
            NSStringFromClass([self class]),
            [self localizedTitle],
            [self localizedBody]];
}

@end

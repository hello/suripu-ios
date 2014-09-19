//
//  SENAccount.m
//  Pods
//
//  Created by Jimmy Lu on 9/3/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "SENAccount.h"

static NSString* kSENAccountDoBFormat = @"yyyy-MM-dd";

@interface SENAccount()

@property (nonatomic, copy, readwrite) NSString* accountId;
@property (nonatomic, copy, readwrite) NSNumber* lastModified;

@end

@implementation SENAccount

- (instancetype)initWithAccountId:(NSString*)accountId
                     lastModified:(NSNumber*)isoLastModDate {
    self = [super init];
    if (self) {
        [self setAccountId:accountId];
        [self setLastModified:isoLastModDate];
    }
    return self;
}

- (void)setBirthMonth:(NSInteger)month day:(NSInteger)day andYear:(NSInteger)year {
    NSDateComponents* components = [[NSDateComponents alloc] init];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    [components setCalendar:[NSCalendar currentCalendar]];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kSENAccountDoBFormat];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [self setBirthdate:[formatter stringFromDate:[components date]]];
}

- (void)setBirthdateInMillis:(NSNumber*)birthdateInMillis {
    if (birthdateInMillis == nil) return;

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kSENAccountDoBFormat];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[birthdateInMillis longLongValue]/1000];
    [self setBirthdate:[formatter stringFromDate:date]];
}

- (NSDateComponents*)birthdateComponents {
    if ([self birthdate] == nil) return nil;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kSENAccountDoBFormat];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components =
        [calendar components:NSCalendarUnitMonth
                             |NSCalendarUnitDay
                             |NSCalendarUnitYear
                    fromDate:[formatter dateFromString:[self birthdate]]];
    return components;
}

@end

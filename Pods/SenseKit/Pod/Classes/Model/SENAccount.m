//
//  SENAccount.m
//  Pods
//
//  Created by Jimmy Lu on 9/3/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "SENAccount.h"

static NSString* kSENAccountDoBFormat = @"yyyy-MM-dd";
static NSString* kSENAccountDateTimeZone = @"GMT";

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
    
    NSDateFormatter* formatter = [self isoDateFormatter];
    [self setBirthdate:[formatter stringFromDate:[components date]]];
}

- (void)setBirthdateInMillis:(NSNumber*)birthdateInMillis {
    if (birthdateInMillis == nil) return;

    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[birthdateInMillis longLongValue]/1000];
    NSDateFormatter* formatter = [self isoDateFormatter];
    [self setBirthdate:[formatter stringFromDate:date]];
}

- (NSDateFormatter*)isoDateFormatter {
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:kSENAccountDoBFormat];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:kSENAccountDateTimeZone]];
    });
    return formatter;
}

- (NSString*)localizedBirthdateWithStyle:(NSDateFormatterStyle)style {
    NSDateFormatter* fromFormatter = [self isoDateFormatter];
    NSDate* date = [fromFormatter dateFromString:[self birthdate]];
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:style
                                          timeStyle:NSDateFormatterNoStyle];
}

- (NSDateComponents*)birthdateComponents {
    if ([self birthdate] == nil) return nil;
    
    NSDateFormatter* formatter = [self isoDateFormatter];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components =
        [calendar components:NSCalendarUnitMonth
                             |NSCalendarUnitDay
                             |NSCalendarUnitYear
                    fromDate:[formatter dateFromString:[self birthdate]]];
    return components;
}

@end

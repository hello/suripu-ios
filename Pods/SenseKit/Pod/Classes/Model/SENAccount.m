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
@property (nonatomic, strong) NSDate* dobDate;

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

- (void)setBirthdate:(NSString *)birthdate {
    _birthdate = birthdate;
    [self setDobDate:nil];
}

- (void)setBirthMonth:(NSInteger)month day:(NSInteger)day andYear:(NSInteger)year {
    NSDateComponents* components = [[NSDateComponents alloc] init];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    [components setCalendar:[NSCalendar autoupdatingCurrentCalendar]];
    
    NSDateFormatter* formatter = [self isoDateFormatter];
    [self setBirthdate:[formatter stringFromDate:[components date]]];
}

- (void)setBirthdateInMillis:(NSNumber*)birthdateInMillis {
    if (birthdateInMillis == nil) return;

    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[birthdateInMillis longLongValue]/1000];
    NSDateFormatter* formatter = [self isoDateFormatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:kSENAccountDateTimeZone]];
    [self setBirthdate:[formatter stringFromDate:date]];
}

- (NSDateFormatter*)isoDateFormatter {
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:kSENAccountDoBFormat];
    });
    return formatter;
}

- (NSString*)localizedBirthdateWithStyle:(NSDateFormatterStyle)style {
    if ([self dobDate] == nil) {
        NSDateFormatter* fromFormatter = [self isoDateFormatter];
        [self setDobDate:[fromFormatter dateFromString:[self birthdate]]];
    }
    return [NSDateFormatter localizedStringFromDate:[self dobDate]
                                          dateStyle:style
                                          timeStyle:NSDateFormatterNoStyle];
}

- (NSDateComponents*)birthdateComponents {
    if ([self birthdate] == nil) return nil;
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateFormatter* formatter = [self isoDateFormatter];
    [formatter setCalendar:calendar];
    
    NSDateComponents* components =
        [calendar components:NSCalendarUnitMonth
                             |NSCalendarUnitDay
                             |NSCalendarUnitYear
                    fromDate:[formatter dateFromString:[self birthdate]]];
    
    return components;
}

@end

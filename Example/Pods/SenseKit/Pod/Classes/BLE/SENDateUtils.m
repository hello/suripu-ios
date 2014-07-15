
#import "SENDateUtils.h"

NSData* SEN_dataForDate(NSDate* date)
{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit)fromDate:date];
    struct SENDateBytes dateBytes;
    NSInteger weekday = components.weekday;
    dateBytes.commandByte = 0x6;
    dateBytes.year = components.year;
    dateBytes.month = components.month;
    dateBytes.day = components.day;
    dateBytes.hour = components.hour;
    dateBytes.minute = components.minute;
    dateBytes.second = components.second;
    dateBytes.weekday = weekday == 1 ? 7 : weekday - 1;
    return [NSData dataWithBytes:&dateBytes length:sizeof(struct SENDateBytes)];
}

NSData* SEN_dataForCurrentDate()
{
    return SEN_dataForDate([NSDate date]);
}

NSDate* SEN_dateForData(NSData* data)
{
    struct SENDateBytes bytes;
    [data getBytes:&bytes length:sizeof(struct SENDateBytes)];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.year = bytes.year;
    components.month = bytes.month;
    components.day = bytes.day;
    components.hour = bytes.hour;
    components.minute = bytes.minute;
    components.second = bytes.second;
    return [calendar dateFromComponents:components];
}

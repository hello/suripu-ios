
#import "SENDateUtils.h"

NSData* SEN_dataForDate(NSDate* date)
{
    
    struct SENDateBytes dateBytes;
    
    /*
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit)fromDate:date];
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
     */
    
    dateBytes.timestamp = [date timeIntervalSince1970] * 1000;
    return [NSData dataWithBytes:&dateBytes length:sizeof(struct SENDateBytes)];  // I am not sure this will lead to alignment or not..
    
}

NSData* SEN_dataForCurrentDate()
{
    return SEN_dataForDate([NSDate date]);
}

NSDate* SEN_dateForData(NSData* data)
{
    struct SENDateBytes bytes;
    [data getBytes:&bytes length:sizeof(struct SENDateBytes)];
    
    /*
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.year = bytes.year;
    components.month = bytes.month;
    components.day = bytes.day;
    components.hour = bytes.hour;
    components.minute = bytes.minute;
    components.second = bytes.second;
    return [calendar dateFromComponents:components];
     */
    
    return [NSDate dateWithTimeIntervalSince1970:bytes.timestamp / 1000];
}

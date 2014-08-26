
#import <Foundation/Foundation.h>

struct SENDateBytes {
    u_int8_t commandByte;
    union {
        struct {
            u_int16_t year;
            u_int8_t month;
            u_int8_t day;
            u_int8_t hour;
            u_int8_t minute;
            u_int8_t second;
            u_int8_t weekday;
        };
        
        uint64_t timestamp;
        
    };
};

NSData* SEN_dataForCurrentDate();

NSDate* SEN_dateForData(NSData* data);

NSData* SEN_dataForDate(NSDate* date);
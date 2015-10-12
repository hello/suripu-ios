
#import "SENKeyedArchiver.h"
#import "CGFloatType.h"

void SENClearModel() {
    [SENKeyedArchiver removeAllObjects];
}

NSDate* SENDateFromNumber(id value) {
    if ([value respondsToSelector:@selector(doubleValue)] && [value doubleValue] > 0)
        return [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000];
    return nil;
}

NSNumber* SENDateMillisecondsSince1970(NSDate* date) {
    // trunc required because the backend, depending on which endpoint we interact
    // with, may reject double / floating point values for the date
    return @(truncCGFloat([date timeIntervalSince1970] * 1000));
}

BOOL SENBoolValue(id value) {
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return NO;
}

id SENObjectOfClass(id object, __unsafe_unretained Class klass) {
    return [object isKindOfClass:klass] ? object : nil;
}
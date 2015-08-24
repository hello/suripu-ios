
#import "SENKeyedArchiver.h"

void SENClearModel() {
    [SENKeyedArchiver removeAllObjects];
}

NSDate* SENDateFromNumber(id value) {
    if ([value respondsToSelector:@selector(doubleValue)] && [value doubleValue] > 0)
        return [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000];
    return nil;
}

id SENObjectOfClass(id object, __unsafe_unretained Class klass) {
    return [object isKindOfClass:klass] ? object : nil;
}
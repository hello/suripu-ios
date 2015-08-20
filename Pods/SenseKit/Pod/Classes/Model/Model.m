
#import "SENKeyedArchiver.h"

void SENClearModel() {
    [SENKeyedArchiver removeAllObjects];
}

id SENObjectOfClass(id object, __unsafe_unretained Class klass) {
    return [object isKindOfClass:klass] ? object : nil;
}
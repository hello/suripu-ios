
#import "Model.h"
#import "SENKeyedArchiver.h"

void SENClearModel() {
    [SENKeyedArchiver removeAllObjects];
    [SENAlarm clearSavedAlarms];
}
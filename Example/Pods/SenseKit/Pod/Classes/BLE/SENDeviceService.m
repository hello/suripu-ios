
#import "SENDeviceService.h"
#import "SENDevice.h"

static NSString* const SENDeviceServiceArchiveKey = @"SENDeviceArchive";

@implementation SENDeviceService

+ (BOOL)hasDevices
{
    return [self archivedDevices].count > 0;
}

+ (void)addDevice:(SENDevice*)device
{
    if (!device)
        return;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %@", device.identifier];
    NSArray* archivedDevices = [self archivedDevices];
    if ([archivedDevices filteredArrayUsingPredicate:predicate].count == 0) {
        [self archiveDevices:[[self archivedDevices] arrayByAddingObject:device]];
    }
}

+ (void)removeDevice:(SENDevice*)device
{
    if (!device)
        return;
    NSArray* devices = [[self archivedDevices] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SENDevice* evaluatedObject, NSDictionary* bindings) {

        return ![evaluatedObject.identifier isEqual:device.identifier];
                                                                           }]];
    [self archiveDevices:devices];
}

+ (void)updateDevice:(SENDevice*)device
{
    if (!device)
        return;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier != %@", device.identifier];
    NSArray* archivedDevices = [[self archivedDevices] filteredArrayUsingPredicate:predicate];
    [self archiveDevices:[archivedDevices arrayByAddingObject:device]];
}

+ (void)removeAllDevices
{
    [NSKeyedArchiver archiveRootObject:nil toFile:[self archivedDevicesPath]];
}

+ (NSArray*)archivedDevices
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivedDevicesPath]] ?: @[];
}

+ (void)archiveDevices:(NSArray*)devices
{
    [NSKeyedArchiver archiveRootObject:devices toFile:[self archivedDevicesPath]];
}

+ (SENDevice*)deviceWithIdentifier:(NSString*)identifier
{
    for (SENDevice* device in [self archivedDevices]) {
        if ([[device.identifier uppercaseString] isEqualToString:[identifier uppercaseString]]) {
            return device;
        }
    }
    return nil;
}

+ (NSString*)archivedDevicesPath
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsPath stringByAppendingPathComponent:SENDeviceServiceArchiveKey];
}

@end

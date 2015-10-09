
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "SENKeyedArchiver.h"

@implementation SENKeyedArchiver

NSString* const SENKeyedArchiverGroupId = @"group.is.hello.sense.data";
NSString* const SENKeyedArchiverStoreName = @"SENKeyedArchiverCache";

static dispatch_queue_t SENKeyedArchiverQueue = nil;

+ (NSString*)datastorePath
{
    NSURL* url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:SENKeyedArchiverGroupId];
    return [[url path] stringByAppendingPathComponent:SENKeyedArchiverStoreName];
}

+ (NSString*)pathForCollection:(NSString*)collectionName {
    return [[self datastorePath] stringByAppendingPathComponent:collectionName];
}

+ (NSArray*)allObjectsInCollection:(NSString*)collectionName
{
    NSArray* objects = [[self collectionWithName:collectionName] allValues];
    if (!objects)
        objects = @[];
    return objects;
}

+ (NSDictionary*)collectionWithName:(NSString*)collectionName {
    NSString* path = [self pathForCollection:collectionName];
    __block NSDictionary* collection = nil;
    [self onInternalQueue:^{
        collection = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }];
    if (!collection)
        collection = @{};
    return collection;
}

+ (void)removeAllObjectsInCollection:(NSString*)collectionName
{
    [self writeCollection:nil withName:collectionName];
}

+ (void)removeAllObjects
{
    NSString* path = [self datastorePath];
    [self onInternalQueue:^{
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }];
}

+ (id)objectsForKey:(NSString*)key inCollection:(NSString*)collectionName
{
    return [self collectionWithName:collectionName][key];
}

+ (void)setObject:(id<NSCoding>)object forKey:(NSString*)key inCollection:(NSString*)collectionName
{
    if (key.length == 0 || collectionName.length == 0)
        return;
    if (!object) {
        [self removeAllObjectsForKey:key inCollection:collectionName];
        return;
    }
    NSMutableDictionary* collection = [[self collectionWithName:collectionName] mutableCopy];
    collection[key] = object;
    [self writeCollection:collection withName:collectionName];
}

+ (void)removeAllObjectsForKey:(nonnull NSString*)key inCollection:(NSString*)collectionName
{
    NSMutableDictionary* collection = [[self collectionWithName:collectionName] mutableCopy];
    [collection removeObjectForKey:key];
    [self writeCollection:collection withName:collectionName];
}

+ (BOOL)hasObjectForKey:(NSString*)key inCollection:(NSString*)collectionName
{
    NSDictionary* collection = [self collectionWithName:collectionName];
    return collection[key] != nil;
}

+ (void)writeCollection:(NSDictionary*)collection withName:(NSString*)collectionName {
    NSString* path = [self pathForCollection:collectionName];
    NSString* datastorePath = [self datastorePath];
    [self onInternalQueue:^{
        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:datastorePath isDirectory:&isDir];
        if (!isDir) {
            NSError* error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:datastorePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            if (error)
                return;
        }
        if (collection) {
            [NSKeyedArchiver archiveRootObject:collection toFile:path];
        } else {
            NSError* error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }

    }];
}

/**
 * Execute task on an internal synchronized queue
 */
+ (void)onInternalQueue:(void(^)())block {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SENKeyedArchiverQueue = dispatch_queue_create("SENKeyedArchiver-Read", NULL);
    });
    dispatch_async(SENKeyedArchiverQueue, block);
}

@end

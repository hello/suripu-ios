
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "SENKeyedArchiver.h"
#import "SENAuthorizationService.h"

@implementation SENKeyedArchiver

NSString* const SENKeyedArchiverGroupId = @"group.is.hello.sense.data";
NSString* const SENKeyedArchiverStoreName = @"SENKeyedArchiverStorage";

static dispatch_queue_t SENKeyedArchiverQueue = nil;

+ (NSString*)datastorePath
{
    NSString* accountID = [SENAuthorizationService accountIdOfAuthorizedUser];
    if (accountID.length == 0)
        return nil;
    NSURL* url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:SENKeyedArchiverGroupId];
    NSString* accountStorePath = [[url path] stringByAppendingPathComponent:accountID];
    return [accountStorePath stringByAppendingPathComponent:SENKeyedArchiverStoreName];
}

+ (NSString*)pathForCollectionNamed:(NSString*)collectionName {
    return [[self datastorePath] stringByAppendingPathComponent:collectionName];
}

+ (NSString*)pathForKey:(NSString*)key inCollectionNamed:(NSString*)collectionName {
    return [[self pathForCollectionNamed:collectionName] stringByAppendingPathComponent:key];
}

+ (NSArray*)allObjectsInCollection:(NSString*)collectionName
{
    return [self unarchiveObjectsAtPath:[self pathForCollectionNamed:collectionName]];
}

+ (void)removeAllObjectsInCollection:(NSString*)collectionName
{
    [self onInternalQueue:^{
        [[NSFileManager defaultManager] removeItemAtPath:[self pathForCollectionNamed:collectionName] error:nil];
    }];
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
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForKey:key inCollectionNamed:collectionName]];
}

+ (void)setObject:(id<NSCoding>)object forKey:(NSString*)key inCollection:(NSString*)collectionName
{
    if (key.length == 0 || collectionName.length == 0)
        return;

    [self onInternalQueue:^{
        NSString* path = [self pathForKey:key inCollectionNamed:collectionName];
        if (!object) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        } else if ([self createDirectoryAtPathIfNeeded:[path stringByDeletingLastPathComponent]]) {
            [NSKeyedArchiver archiveRootObject:object toFile:path];
        }
    }];
}

+ (void)removeAllObjectsForKey:(nonnull NSString*)key inCollection:(NSString*)collectionName
{
    [self setObject:nil forKey:key inCollection:collectionName];
}

+ (BOOL)hasObjectForKey:(NSString*)key inCollection:(NSString*)collectionName
{
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self pathForKey:key inCollectionNamed:collectionName]
                                                       isDirectory:&isDir];
    return exists && !isDir;
}

/**
 * Creates a directory if needed, returning NO if directory does not exist
 */
+ (BOOL)createDirectoryAtPathIfNeeded:(NSString*)path {
    NSError* error = nil;
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (!isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    return error == nil;
}

+ (NSArray*)unarchiveObjectsAtPath:(NSString*)path {
    __block NSMutableArray* objects = [NSMutableArray new];
    [self onInternalQueue:^{
        for (NSString* filePath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil]) {
            if (!filePath)
                continue;
            id object = [NSKeyedUnarchiver unarchiveObjectWithFile:[path stringByAppendingPathComponent:filePath]];
            if (object)
                [objects addObject:object];
        }
    }];
    return [objects copy];
}

/**
 * Execute task on an internal synchronized queue
 */
+ (void)onInternalQueue:(void(^)())block {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SENKeyedArchiverQueue = dispatch_queue_create("SENKeyedArchiver-Read", NULL);
    });
    dispatch_sync(SENKeyedArchiverQueue, block);
}

@end

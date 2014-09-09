
#import <YapDatabase/YapDatabase.h>
#import "SENKeyedArchiver.h"

@implementation SENKeyedArchiver

static NSString* const SENKeyedArchiverStoreName = @"SENKeyedArchiverStore";

+ (YapDatabase*)datastore
{
    static YapDatabase* database = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        database = [[YapDatabase alloc] initWithPath:[self datastorePath]];
    });
    return database;
}

+ (NSString*)datastorePath
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsPath stringByAppendingPathComponent:SENKeyedArchiverStoreName];
}

+ (YapDatabaseConnection*)mainConnection
{
    static YapDatabaseConnection* connection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connection = [[self datastore] newConnection];
    });
    return connection;
}

+ (NSArray*)allObjectsInCollection:(NSString*)collectionName
{
    __block NSMutableArray* objects = [[NSMutableArray alloc] init];
    [[self mainConnection] readWithBlock:^(YapDatabaseReadTransaction* transaction) {
        for (NSString* key in [transaction allKeysInCollection:collectionName]) {
            id obj = [transaction objectForKey:key inCollection:collectionName];
            if (obj)
                [objects addObject:obj];
        }
    }];
    return objects;
}

+ (void)removeAllObjectsInCollection:(NSString*)collectionName
{
    [[self mainConnection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInCollection:collectionName];
    }];
}

+ (NSSet*)objectsForKey:(NSString*)key inCollection:(NSString*)collectionName
{
    __block id objects = nil;
    [[self mainConnection] readWithBlock:^(YapDatabaseReadTransaction* transaction) {
        objects = [transaction objectForKey:key inCollection:collectionName];
    }];
    return objects;
}

+ (void)setObject:(id)object forKey:(NSString*)key inCollection:(NSString*)collectionName
{
    if (!object) {
        [self removeAllObjectsForKey:key inCollection:collectionName];
        return;
    }
    [[self mainConnection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction* transaction) {
        [transaction setObject:object forKey:key inCollection:collectionName];
    }];
}

+ (void)removeAllObjectsForKey:(NSString*)key inCollection:(NSString*)collectionName
{
    [[self mainConnection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction* transaction) {
        [transaction removeObjectForKey:key inCollection:collectionName];
    }];
}

@end

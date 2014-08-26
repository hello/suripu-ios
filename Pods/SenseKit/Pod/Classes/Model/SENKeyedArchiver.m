
#import "SENKeyedArchiver.h"

@implementation SENKeyedArchiver

+ (NSSet*)objectsForKey:(NSString*)key
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForKey:key]] ?: [NSSet set];
}

+ (NSString*)filePathForKey:(NSString*)key
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsPath stringByAppendingPathComponent:key];
}

+ (void)setObjects:(NSSet*)objects forKey:(NSString*)key
{
    [NSKeyedArchiver archiveRootObject:objects toFile:[self filePathForKey:key]];
}

+ (void)addObject:(id<NSCoding>)object toObjectsForKey:(NSString*)key
{
    if (!object)
        return;

    NSMutableSet* objects = [[self objectsForKey:key] mutableCopy];
    [objects addObject:object];
    [self setObjects:objects forKey:key];
}

+ (void)removeAllObjectsForKey:(NSString*)key
{
    [self setObjects:nil forKey:key];
}

+ (void)removeObject:(id<NSCoding>)object fromObjectsForKey:(NSString*)key
{
    NSMutableSet* objects = [[self objectsForKey:key] mutableCopy];
    [objects removeObject:object];
    [self setObjects:objects forKey:key];
}
@end

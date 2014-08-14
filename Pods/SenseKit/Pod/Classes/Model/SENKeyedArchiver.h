
#import <Foundation/Foundation.h>

/**
 *  A utility class for handling archiving sets of objects to disk
 */
@interface SENKeyedArchiver : NSObject

/**
 *  Retrieves objects stored under a particular key
 *
 *  @param key identifier of the objects to retrieve
 *
 *  @return a set of matching objects or an empty set
 */
+ (NSSet*)objectsForKey:(NSString*)key;

/**
 *  Persists NSCoding-compliant objects to be retrieved later using a key
 *
 *  @param objects objects to save
 *  @param key     identifier of the objects to persist
 */
+ (void)setObjects:(NSSet*)objects forKey:(NSString*)key;

/**
 *  Adds an object to a collection stored under a particular key
 *
 *  @param object object to add
 *  @param key    identifier of the persisted collection
 */
+ (void)addObject:(id<NSCoding>)object toObjectsForKey:(NSString*)key;

/**
 *  Removes an object from a collection stored under a particular key
 *
 *  @param object object to remove
 *  @param key    identifier of the persisted collection
 */
+ (void)removeObject:(id<NSCoding>)object fromObjectsForKey:(NSString*)key;

/**
 *  Removes all objects from a collction stored under a particular key
 *
 *  @param key identifier of the persisted collection
 */
+ (void)removeAllObjectsForKey:(NSString*)key;
@end

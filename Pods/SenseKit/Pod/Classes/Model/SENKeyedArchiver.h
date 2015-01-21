
#import <Foundation/Foundation.h>

@class YapDatabase;

/**
 *  A utility class for handling archiving sets of objects to disk
 */
@interface SENKeyedArchiver : NSObject

+ (YapDatabase*)datastore;

/**
 *  Retrieves all objects in a given bucket
 *
 *  @param collectionName name of the bucket
 *
 *  @return array of matching objects
 */
+ (NSArray*)allObjectsInCollection:(NSString*)collectionName;

/**
 *  Removes all objects in a given bucket
 *
 *  @param collectionName name of the bucket
 */
+ (void)removeAllObjectsInCollection:(NSString*)collectionName;

/**
 *  Nuke it from the sky
 */
+ (void)removeAllObjects;

/**
 *  Retrieves objects stored under a particular key
 *
 *  @param key            identifier of the objects to retrieve
 *  @param collectionName storage bucket of the objects
 *
 *  @return a set of matching objects or an empty set
 */
+ (id)objectsForKey:(NSString*)key inCollection:(NSString*)collectionName;

/**
 *  Persists NSCoding-compliant objects to be retrieved later using a key
 *
 *  @param objects        objects to save
 *  @param key            identifier of the objects to persist
 *  @param collectionName storage bucket of the objects
 */
+ (void)setObject:(id)objects forKey:(NSString*)key inCollection:(NSString*)collectionName;

/**
 *  Removes all objects from a collection stored under a particular key
 *
 *  @param key            identifier of the persisted collection
 *  @param collectionName storage bucket of the objects
 */
+ (void)removeAllObjectsForKey:(NSString*)key inCollection:(NSString*)collectionName;

/**
 *  Checks for the presence of an object in a collection with a particular key
 *
 *  @param key            identifier of the persisted object
 *  @param collectionName storage bucket of the objects
 *
 *  @return YES if an object exists with that key in the specified collection
 */
+ (BOOL)hasObjectForKey:(NSString*)key inCollection:(NSString*)collectionName;

@end

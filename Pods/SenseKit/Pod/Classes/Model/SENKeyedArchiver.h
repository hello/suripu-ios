
#import <Foundation/Foundation.h>

/**
 *  A utility class for handling archiving sets of objects to disk
 */
@interface SENKeyedArchiver : NSObject

/**
 * Path to the internal datastore directory
 */
+ (nonnull NSString*)datastorePath;

/**
 *  Retrieves all objects in a given bucket
 *
 *  @param collectionName name of the bucket
 *
 *  @return array of matching objects
 */
+ (nonnull NSArray*)allObjectsInCollection:(nonnull NSString*)collectionName;

/**
 *  Removes all objects in a given bucket
 *
 *  @param collectionName name of the bucket
 */
+ (void)removeAllObjectsInCollection:(nonnull NSString*)collectionName;

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
+ (nullable id)objectsForKey:(nonnull NSString*)key inCollection:(nonnull NSString*)collectionName;

/**
 *  Persists NSCoding-compliant objects to be retrieved later using a key
 *
 *  @param objects        objects to save
 *  @param key            identifier of the objects to persist
 *  @param collectionName storage bucket of the objects
 */
+ (void)setObject:(nullable id<NSCoding>)objects
           forKey:(nonnull NSString*)key
     inCollection:(nonnull NSString*)collectionName;

/**
 *  Removes all objects from a collection stored under a particular key
 *
 *  @param key            identifier of the persisted collection
 *  @param collectionName storage bucket of the objects
 */
+ (void)removeAllObjectsForKey:(nonnull NSString*)key inCollection:(nonnull NSString*)collectionName;

/**
 *  Checks for the presence of an object in a collection with a particular key
 *
 *  @param key            identifier of the persisted object
 *  @param collectionName storage bucket of the objects
 *
 *  @return YES if an object exists with that key in the specified collection
 */
+ (BOOL)hasObjectForKey:(nonnull NSString*)key inCollection:(nonnull NSString*)collectionName;

@end

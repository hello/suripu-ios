//
//  SENLocalPreferences.h
//  Pods
//
//  Created by Jimmy Lu on 2/19/15.

#import <Foundation/Foundation.h>

extern NSString* const SENLocalPrefAppGroup;
extern NSString* const SENLocalPrefDidChangeNotification;

@interface SENLocalPreferences : NSObject

/**
 * @return a shared instance of SENLocalPrefeference
 */
+ (instancetype)sharedPreferences;

/**
 * @method setUserPreference:forKey:
 *
 * @discussion
 * Set user specific preferences that vary based on the user / account id
 * of the signed in user.  If preference provided is nil, it will remove whatever
 * is currently referenced by the key for the user
 *
 * @param preference: a preference object that is of a Property Lists data type
 * @param key: the key to reference the object
 * @return YES if preference was set, NO otherwise (if key is not provided or not signed in)
 */
- (BOOL)setUserPreference:(id)preference forKey:(NSString*)key;

/**
 * @method userPreferenceForKey:
 *
 * @param key to the preference saved
 * @return the user preference for the specified key or nil
 */
- (id)userPreferenceForKey:(NSString*)key;

/**
 * @method setSessionPreference:forKey:
 *
 * @discussion
 * Set a preference that is intended to be session based and disposable upon
 * authentication changes.  To remove a single session preference, pass in nil.
 * To remove all session preferences, call removeSessionPreferences
 *
 * @param preference: a preference object that is of a Property Lists data type
 * @param key: the key to reference the object
 * @return YES if preference was set, NO otherwise (if key is not provided)
 *
 * @see @method removeSessionPreferences
 */
- (BOOL)setSessionPreference:(id)preference forKey:(NSString*)key;

/**
 * @method sessionPreferenceForKey:
 *
 * @param key to the preference saved
 * @return the session preference for the specified key or nil
 */
- (id)sessionPreferenceForKey:(NSString*)key;

/**
 * @method removeSessionPreferences
 *
 * @discussion
 * Remove all session preferences
 */
- (void)removeSessionPreferences;

/**
 * @method setPersistentPreference:forKey:
 *
 * @discussion
 * Set a preference that is intended be persisted to disk and applicable for all
 * users of the application.  Preferences will only be destroyed if application
 * is uninstalled or a calling the underlying NSUserDefaults method to wipe out
 * all defaults for the bundle.
 *
 * To remove 1 persistentPreference, pass in nil as a preference for the key
 *
 * @param preference: a preference object that is of a Property Lists data type
 * @param key: the key to reference the object
 */
- (void)setPersistentPreference:(id)preference forKey:(NSString*)key;

/**
 * @method persistentPreferenceForKey:
 *
 * @param key to the preference saved
 * @return the persistent preference for the specified key or nil
 */
- (id)persistentPreferenceForKey:(NSString*)key;

@end

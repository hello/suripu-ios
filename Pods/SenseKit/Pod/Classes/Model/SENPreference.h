//
//  SENPreference.h
//  Pods
//
//  Created by Jimmy Lu on 1/15/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENPreferenceType) {
    SENPreferenceTypeUnknown = 0,
    /**
     *  Enable support for enhanced audio processing
     */
    SENPreferenceTypeEnhancedAudio = 1,
    /**
     *  Represent time in 24-hour format
     */
    SENPreferenceTypeTime24 = 2,
    /**
     *  Represent temperature values in Celcius
     */
    SENPreferenceTypeTempCelcius = 3,
    /**
     *  Receive push notifications for score in the morning
     */
    SENPreferenceTypePushScore = 4,
    /**
     *  Receive push notifications for poor sleep environment in the evening
     */
    SENPreferenceTypePushConditions = 5,
};

extern NSString* const SENPreferenceNameEnhancedAudio;
extern NSString* const SENPreferenceNameTemp;
extern NSString* const SENPreferenceNameTime;
extern NSString* const SENPreferenceNamePushScore;
extern NSString* const SENPreferenceNamePushConditions;

@interface SENPreference : NSObject

@property (nonatomic, assign, readonly) SENPreferenceType type;
@property (nonatomic, assign, readwrite, getter = isEnabled) BOOL enabled;

/**
 * @param type: the type of the preference
 * @return name: the name of the preference used by the api
 */
+ (NSString*)nameFromType:(SENPreferenceType)type;

/**
 * @method initWithType:enable
 *
 * @param type: the type of the prefence
 * @param enable: YES to enable, NO otherwise
 * @return initialized instance with the given type and enable flag
 */
- (instancetype)initWithType:(SENPreferenceType)type enable:(BOOL)enable;

/**
 * @method initWithName:value
 *
 * @param name: the server dictated name of the preference
 * @param value: a number object that determines the enable state of the pref
 * @return initialized instance, if name is specified and recognized
 */
- (instancetype)initWithName:(NSString*)name value:(NSNumber*)value;

/**
 * @method initWithDictionary:
 *
 * @param dictionary: a raw json-to-dictionary representation of a preference
 * @return initialized instance
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

/**
 * @method dictionaryValue
 * @return a dictionary representation of the instance that would be identical
 *         a dictionary that would be used to initialize an instace
 *
 * @see @method initWithDictionary:
 */
- (NSDictionary*)dictionaryValue;

@end

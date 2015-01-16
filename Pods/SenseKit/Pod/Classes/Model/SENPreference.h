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
    SENPreferenceTypeEnhancedAudio = 1
};

@interface SENPreference : NSObject

@property (nonatomic, assign, readonly) SENPreferenceType type;
@property (nonatomic, assign, readwrite) BOOL enabled;

/**
 * @method initWithType:enable
 *
 * @param type: the type of the prefence
 * @param enable: YES to enable, NO otherwise
 * @return initialized instance with the given type and enable flag
 */
- (instancetype)initWithType:(SENPreferenceType)type enable:(BOOL)enable;

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

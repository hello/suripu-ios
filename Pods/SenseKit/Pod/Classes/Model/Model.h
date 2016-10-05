
#import <Foundation/Foundation.h>
#import "SENAccount.h"
#import "SENAlarm.h"
#import "SENAnswer.h"
#import "SENInsight.h"
#import "SENQuestion.h"
#import "SENSensor.h"
#import "SENTimeline.h"
#import "SENSound.h"
#import "SENPreference.h"
#import "SENLocalPreferences.h"
#import "SENSupportTopic.h"
#import "SENAppStats.h"
#import "SENAppUnreadStats.h"
#import "SENPairedDevices.h"
#import "SENSenseMetadata.h"
#import "SENPillMetadata.h"
#import "SENDevicePairingInfo.h"
#import "SENRemoteImage.h"
#import "SENTrends.h"
#import "SENTrendsGraph.h"
#import "SENSleepSoundDurations.h"
#import "SENSleepSounds.h"
#import "SENSleepSoundStatus.h"
#import "SENSleepSoundRequest.h"
#import "SENSleepSoundsState.h"
#import "SENDFUStatus.h"
#import "SENSpeechResult.h"
#import "SENFeatures.h"
#import "SENSwapStatus.h"
#import "SENSensorStatus.h"
#import "SENSensorDataRequest.h"
#import "SENExpansion.h"
#import "SENAlarmCollection.h"

void SENClearModel();

/**
 *  Returns a date for the number value in milliseconds
 *
 *  @param value number of milliseconds since the epoch
 *
 *  @return a Date representing value
 */
NSDate* SENDateFromNumber(id value);

/**
 *  Creates a number from an NSDate object suitable for passing
 *  to the API
 *
 *  @param date a date
 *
 *  @return a number or nil
 */
NSNumber* SENDateMillisecondsSince1970(NSDate* date);

/**
 *  @param value to translate in to a BOOL value
 *
 *  @return BOOL value or NO if value cannot be translated
 */
BOOL SENBoolValue(id value);

/**
 *  Checks the type of an object, returning the object if it
 *  matches the intended class
 *
 *  @param object object to validate
 *  @param klass  intended object class
 *
 *  @return object if it is of type klass, else nil
 */
id SENObjectOfClass(id object, __unsafe_unretained Class klass);

/**
 *  Checks to see if two objects are equal.  If both objects are nil, then the
 *  objects are equal
 *
 *  @param obj1: first object to compare
 *  @param obj2: second object to compare
 *  @return YES if equal. NO Otherwise
 */
BOOL SENObjectIsEqual(id obj1, id obj2);
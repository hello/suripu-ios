
#import <Foundation/Foundation.h>
#import "SENAccount.h"
#import "SENAlarm.h"
#import "SENAnswer.h"
#import "SENDevice.h"
#import "SENInsight.h"
#import "SENQuestion.h"
#import "SENSense.h"
#import "SENSensor.h"
#import "SENTimeline.h"
#import "SENSound.h"
#import "SENTrend.h"
#import "SENPreference.h"
#import "SENLocalPreferences.h"
#import "SENSupportTopic.h"

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
 *  Checks the type of an object, returning the object if it
 *  matches the intended class
 *
 *  @param object object to validate
 *  @param klass  intended object class
 *
 *  @return object if it is of type klass, else nil
 */
id SENObjectOfClass(id object, __unsafe_unretained Class klass);
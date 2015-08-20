//
//  SENTimelineSegment.h
//  Pods
//
//  Created by Delisa Mason on 7/9/15.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

typedef NS_ENUM(NSInteger, SENTimelineSegmentSleepState) {
    SENTimelineSegmentSleepStateUnknown,
    SENTimelineSegmentSleepStateAwake,
    SENTimelineSegmentSleepStateLight,
    SENTimelineSegmentSleepStateMedium,
    SENTimelineSegmentSleepStateSound,
};

typedef NS_ENUM(NSInteger, SENTimelineSegmentType) {
    SENTimelineSegmentTypeInBed,
    SENTimelineSegmentTypeGenericMotion,
    SENTimelineSegmentTypePartnerMotion,
    SENTimelineSegmentTypeGenericSound,
    SENTimelineSegmentTypeSnored,
    SENTimelineSegmentTypeSleepTalked,
    SENTimelineSegmentTypeLight,
    SENTimelineSegmentTypeLightsOut,
    SENTimelineSegmentTypeSunset,
    SENTimelineSegmentTypeSunrise,
    SENTimelineSegmentTypeGotInBed,
    SENTimelineSegmentTypeFellAsleep,
    SENTimelineSegmentTypeGotOutOfBed,
    SENTimelineSegmentTypeWokeUp,
    SENTimelineSegmentTypeAlarmRang,
    SENTimelineSegmentTypeUnknown
};

typedef NS_ENUM(NSInteger, SENTimelineSegmentAction) {
    SENTimelineSegmentActionNone       = 0,
    SENTimelineSegmentActionAdjustTime = 1 << 1,
    SENTimelineSegmentActionApprove    = 1 << 2,
    SENTimelineSegmentActionRemove     = 1 << 3,
    SENTimelineSegmentActionIncorrect  = 1 << 4
};

SENTimelineSegmentSleepState SENTimelineSegmentSleepStateFromString(NSString *segmentType);
SENTimelineSegmentType SENTimelineSegmentTypeFromString(NSString *segmentType);
NSString* SENTimelineSegmentTypeNameFromType(SENTimelineSegmentType type);
SENTimelineSegmentAction SENTimelineSegmentActionFromStrings(NSArray* actions);

@interface SENTimelineSegment : NSObject <NSCoding, SENSerializable, SENUpdatable>

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSTimeZone* timezone;
@property (nonatomic, strong) NSString* message;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) SENTimelineSegmentType type;
@property (nonatomic) NSInteger sleepDepth;
@property (nonatomic) SENTimelineSegmentSleepState sleepState;
@property (nonatomic) SENTimelineSegmentAction possibleActions;

- (BOOL)canPerformAction:(SENTimelineSegmentAction)action;
@end
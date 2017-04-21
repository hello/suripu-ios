//
//  SENVoiceCommandGroup.h
//  Pods
//
//  Created by Jimmy Lu on 4/19/17.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

@class SENRemoteImage;

@interface SENVoiceCommandSubGroup : NSObject <SENSerializable>

@property (nonatomic, copy, readonly) NSString* localizedTitle;
@property (nonatomic, copy, readonly) NSArray<NSString*>* commands;

@end

@interface SENVoiceCommandGroup : NSObject <SENSerializable>

@property (nonatomic, copy, readonly) NSString* localizedTitle;
@property (nonatomic, copy, readonly) NSString* localizedExample;
@property (nonatomic, strong, readonly) SENRemoteImage* iconImage;
@property (nonatomic, strong, readonly) NSArray<SENVoiceCommandSubGroup*>* groups;

@end

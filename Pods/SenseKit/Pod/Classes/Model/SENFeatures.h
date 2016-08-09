//
//  SENFeatures.h
//  Pods
//
//  Created by Jimmy Lu on 8/4/16.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

@interface SENFeatures : NSObject <NSCoding, SENSerializable>

@property (nonatomic, assign, getter=hasVoice, readonly) BOOL voice;

+ (instancetype)savedFeatures;
- (void)save;
- (void)remove;

@end

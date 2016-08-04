//
//  SENFeatures.h
//  Pods
//
//  Created by Jimmy Lu on 8/4/16.
//
//

#import <Foundation/Foundation.h>

@interface SENFeatures : NSObject

@property (nonatomic, assign, getter=hasVoice, readonly) BOOL voice;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

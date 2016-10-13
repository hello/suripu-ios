//
//  HEMVoiceCommand.h
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMVoiceCommandExamples : NSObject

@property (nonatomic, copy) NSString* categoryName;
@property (nonatomic, copy) NSArray<NSString*>* commands;

@end

@interface HEMVoiceCommandGroup : NSObject

@property (nonatomic, copy) NSString* categoryName;
@property (nonatomic, copy, readonly) NSString* example;
@property (nonatomic, copy) NSString* iconNameSmall;
@property (nonatomic, copy) NSString* iconNameLarge;
@property (nonatomic, strong) NSArray<HEMVoiceCommandExamples*>* examples;

@end

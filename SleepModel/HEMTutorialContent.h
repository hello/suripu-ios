//
//  HEMTutorialContent.h
//  Sense
//
//  Created by Jimmy Lu on 6/9/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMTutorialContent : NSObject

@property (nonatomic, copy, readonly)   NSString* title;
@property (nonatomic, copy, readonly)   NSString* text;
@property (nonatomic, strong, readonly) UIImage* image;
@property (nonatomic, copy, readonly)   NSString* videoPath;

- (instancetype)initWithTitle:(NSString*)title
                         text:(NSString*)text
                        image:(UIImage*)image;

- (instancetype)initWithTitle:(NSString *)title
                         text:(NSString *)text
                        image:(UIImage *)image
                    videoPath:(NSString*)videoPath;

- (BOOL)hasVideoContent;

@end

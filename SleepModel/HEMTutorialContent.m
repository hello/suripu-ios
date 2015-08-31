//
//  HEMTutorialContent.m
//  Sense
//
//  Created by Jimmy Lu on 6/9/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTutorialContent.h"

@interface HEMTutorialContent()

@property (nonatomic, copy)   NSString* title;
@property (nonatomic, copy)   NSString* content;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, copy)   NSString* videoPath;

@end

@implementation HEMTutorialContent

- (instancetype)initWithTitle:(NSString*)title
                         text:(NSString*)text
                        image:(UIImage*)image {
    return [self initWithTitle:title
                          text:text
                         image:image
                     videoPath:nil];
}

- (instancetype)initWithTitle:(NSString *)title
                         text:(NSString *)text
                        image:(UIImage *)image
                    videoPath:(NSString*)videoPath {
    self = [super init];
    if (self) {
        _title = [title copy];
        _text = [text copy];
        _image = image;
        _videoPath = [videoPath copy];
    }
    return self;
}

- (BOOL)hasVideoContent {
    return [self image] && [[self videoPath] length] > 0;
}

@end

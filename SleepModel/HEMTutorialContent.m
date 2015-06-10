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

@end

@implementation HEMTutorialContent

- (instancetype)initWithTitle:(NSString*)title
                         text:(NSString*)text
                        image:(UIImage*)image {
    self = [super init];
    if (self) {
        _title = [title copy];
        _text = [text copy];
        _image = image;
    }
    return self;
}

@end

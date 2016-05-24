//
//  UIImage+HEMCompression.m
//  Sense
//
//  Created by Jimmy Lu on 5/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UIImage+HEMCompression.h"

@implementation UIImage (HEMCompression)

- (void)jpegDataWithCompression:(CGFloat)compression completion:(UIImageCompressionCompletion)completion {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSData* data = UIImageJPEGRepresentation(strongSelf, compression);
        dispatch_async(dispatch_get_main_queue(), ^{
            completion (data);
        });
    });
}

@end

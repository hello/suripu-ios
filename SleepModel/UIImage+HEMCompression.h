//
//  UIImage+HEMCompression.h
//  Sense
//
//  Created by Jimmy Lu on 5/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^UIImageCompressionCompletion)(NSData* _Nullable data);

@interface UIImage (HEMCompression)

- (void)jpegDataWithCompression:(CGFloat)compression
                     completion:(UIImageCompressionCompletion)completion;

@end

NS_ASSUME_NONNULL_END
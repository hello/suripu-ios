//
//  SENAPIPhoto.h
//  Pods
//
//  Created by Jimmy Lu on 5/20/16.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

/**
 * Supported types
 */
typedef NS_ENUM(NSUInteger, SENAPIPhotoType) {
    SENAPIPhotoTypeJpeg = 1,
    SENAPIPhotoTypePng
};

NS_ASSUME_NONNULL_BEGIN

@interface SENAPIPhoto : NSObject

+ (void)uploadProfilePhoto:(NSData*)photoData
                      type:(SENAPIPhotoType)photoType
                  progress:(nullable SENAPIProgressBlock)progress
                completion:(nullable SENAPIDataBlock)completion;

+ (void)deleteProfilePhoto:(nullable SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END
//
//  SENAPIPhoto.m
//  Pods
//
//  Created by Jimmy Lu on 5/20/16.
//
//

#import "SENAPIPhoto.h"

static NSString* const SENAPIPhotoResource = @"v1/photo";
static NSString* const SENAPIPhotoResourcePathProfile = @"profile";
static NSString* const SENAPIPhotoName = @"file";

@implementation SENAPIPhoto

+ (void)photoExt:(NSString**)ext mimeType:(NSString**)mimeType forType:(SENAPIPhotoType)type {
    switch (type) {
        case SENAPIPhotoTypePng:
            *ext = @"png";
            *mimeType = @"image/png";
            return;
        SENAPIPhotoTypeJpeg:
        default:
            *ext = @"jpg";
            *mimeType = @"image/jpeg";
            return;
    }
}

+ (void)uploadProfilePhoto:(NSData*)photoData
                      type:(SENAPIPhotoType)photoType
                  progress:(SENAPIProgressBlock)progress
                completion:(SENAPIDataBlock)completion {
    NSString* fileExt = nil;
    NSString* mimeType = nil;
    [self photoExt:&fileExt mimeType:&mimeType forType:photoType];
    
    NSString* path = [SENAPIPhotoResource stringByAppendingPathComponent:SENAPIPhotoResourcePathProfile];
    NSString* fileName = [SENAPIPhotoName stringByAppendingPathExtension:fileExt];
    [SENAPIClient UPLOAD:photoData
                    name:SENAPIPhotoName
                fileName:fileName
                mimeType:mimeType
                   toURL:path
              parameters:nil
                progress:progress
              completion:completion];
}

+ (void)deleteProfilePhoto:(SENAPIDataBlock)completion {
    NSString* path = [SENAPIPhotoResource stringByAppendingPathComponent:SENAPIPhotoResourcePathProfile];
    [SENAPIClient DELETE:path parameters:nil completion:completion];
}

@end

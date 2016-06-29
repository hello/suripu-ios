//
//  SENAPIShare.m
//  Pods
//
//  Created by Jimmy Lu on 6/21/16.
//
//

#import "SENAPIShare.h"
#import "SENShareable.h"

NSString* const SENAPIShareErrorDomain = @"is.hello.api.share";

static NSString* const SENAPIShareResource = @"v2/sharing";
static NSString* const SENAPIShareReqType = @"type";
static NSString* const SENAPIShareReqId = @"id";
static NSString* const SENAPIShareResUrl = @"url";

@implementation SENAPIShare

+ (NSError*)errorWithCode:(SENAPIShareError)errorCode {
    return [NSError errorWithDomain:SENAPIShareErrorDomain
                               code:errorCode
                           userInfo:nil];
}

+ (void)shareURLFor:(id<SENShareable>)shareable
         completion:(SENAPIDataBlock)completion {
    NSString* identifier = [shareable identifier];
    NSString* type = [shareable shareType];
    if (!identifier || !type) {
        completion (nil, [self errorWithCode:SENAPIShareErrorInvalidArgument]);
        return;
    }
    
    NSDictionary* body = @{SENAPIShareReqType : type,
                           SENAPIShareReqId : identifier};
    NSString* path = [SENAPIShareResource stringByAppendingPathComponent:type];
    [SENAPIClient POST:path parameters:body completion:^(id data, NSError *error) {
        NSString* url = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            url = data[SENAPIShareResUrl];
        }
        completion (url, error);
    }];
}

@end

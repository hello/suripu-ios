
#import "AFHTTPSessionManager.h"

#import "SENAPIRoom.h"
#import "SENAPIClient.h"

@implementation SENAPIRoom

+ (void)currentWithCompletion:(SENAPIDataBlock)completion
{
    [[SENAPIClient HTTPSessionManager] GET:@"/room/current" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
}

@end

//
//  SENAPISupport.m
//  Pods
//
//  Created by Jimmy Lu on 6/25/15.
//
//

#import "SENAPISupport.h"
#import "SENSupportTopic.h"

static NSString* const SENAPISupportEndpoint = @"v1/support";
static NSString* const SENAPISupportPathTopics = @"topics";

@implementation SENAPISupport

+ (void)supportTopics:(SENAPIDataBlock)completion {
    if (!completion) {
        return;
    }
    
    [SENAPIClient GET:[SENAPISupportEndpoint stringByAppendingPathComponent:SENAPISupportPathTopics]
           parameters:nil
           completion:^(id data, NSError *error) {
               NSMutableArray* topics = nil;
               if (!error && [data isKindOfClass:[NSArray class]]) {
                   topics = [NSMutableArray arrayWithCapacity:[data count]];
                   for (id obj in data) {
                       if ([obj isKindOfClass:[NSDictionary class]]) {
                           [topics addObject:[[SENSupportTopic alloc] initWithRawResponse:obj]];
                       }
                   }
               }
               completion (topics, error);
           }];
}

@end

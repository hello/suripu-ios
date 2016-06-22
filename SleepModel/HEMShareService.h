//
//  HEMShareService.h
//  Sense
//
//  Created by Jimmy Lu on 6/21/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SenseKit.h>
#import <SenseKit/SENShareable.h>

typedef void(^HEMShareUrlHandler)(NSString* url, NSError* error);

@interface HEMShareService : SENService

- (void)shareUrlFor:(id<SENShareable>)shareable completion:(HEMShareUrlHandler)completion;

@end

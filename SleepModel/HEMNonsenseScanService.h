//
//  HEMNonsenseScanService.h
//  Sense
//
//  Created by Kevin MacWhinnie on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

@protocol HEMNonsenseScanServiceDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface HEMNonsenseScanService : SENService <NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (nonatomic, weak, nullable) id <HEMNonsenseScanServiceDelegate> delegate;

- (void)start;
- (void)stop;

- (nonnull NSString*)addressForNonsense:(nonnull NSNetService*)nonsense;

@end

@protocol HEMNonsenseScanServiceDelegate <NSObject>
@required

- (void)nonsenseScanService:(HEMNonsenseScanService*)scanService
               detectedHost:(NSNetService*)nonsense;

- (void)nonsenseScanService:(HEMNonsenseScanService*)scanService
            hostDisappeared:(NSNetService*)nonsense;

@end

NS_ASSUME_NONNULL_END

//
//  HEMSelectHostDataSource.h
//  Sense
//
//  Created by Kevin MacWhinnie on 12/8/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMSelectHostDataSource : NSObject <UITableViewDataSource>

- (void)addDiscoveredHost:(nonnull NSNetService*)host;
- (void)removeDiscoveredHost:(nonnull NSNetService*)host;

- (nullable NSString*)hostAtIndexPath:(NSIndexPath *)indexPath;
- (void)displayCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END

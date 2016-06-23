//
//  SENShareable.h
//  Pods
//
//  Created by Jimmy Lu on 6/21/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @discussion
 * Protocol that defines the necessary information for obtaining
 * a share url from the Sense API
 */
@protocol SENShareable <NSObject>

@required
/**
 * @return a unique identifier for the shareable object
 */
- (NSString*)identifier;

/**
 * @return a classifier for the shareable object
 */
- (NSString*)shareType;

@end

NS_ASSUME_NONNULL_END

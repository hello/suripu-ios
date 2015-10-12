//
//  SENAppStats.h
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import <Foundation/Foundation.h>

@interface SENAppStats : NSObject

/**
 * @property lastViewedInsights
 *
 * @discussion
 * The date in which insights were last viewed.  It may be null if account has
 * yet to update this property before
 */
@property (nonatomic, strong, nullable) NSDate* lastViewedInsights;

/**
 * Initialize the object with the provied raw dictionary values retrieved from
 * an API request
 *
 * @param dictionary: dictionary containing raw values retrieved from API
 */
- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary*)dictionary;

/**
 * @return a raw dictionary containing the values encapsulated in this object 
 *         that can be returned as the body of a request to the API
 */
- (nonnull NSDictionary*)dictionaryValue;

@end

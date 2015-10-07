//
//  SENAppUnreadStats.h
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import <Foundation/Foundation.h>

@interface SENAppUnreadStats : NSObject

@property (nonatomic, assign, readonly, getter=hasUnreadInsights) BOOL unreadInsights;
@property (nonatomic, assign, readonly, getter=hasUnreadQuestions) BOOL unreadQuestions;

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

//
//  SENSerializable.h
//  Pods
//
//  Created by Delisa Mason on 7/9/15.
//
//

@protocol SENSerializable <NSObject>

/**
 *  Generate an object, populating properties from a dictionary
 *
 *  @param data data representing object properties
 */
- (instancetype)initWithDictionary:(NSDictionary*)data;

/**
 *  Updates an object, populating properties from a dictionary while
 *  ignoring missing values
 *
 *  @param data data representing object properties
 *
 *  @return YES if any properties were changed
 */
- (BOOL)updateWithDictionary:(NSDictionary*)data;

@end
//
//  SENSystemAlert.h
//  Pods
//
//  Created by Jimmy Lu on 11/8/16.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SENAlertCategory) {
    SENAlertCategoryUnknown = 0,
    SENAlertCategoryExpansionUnreachable
};

@interface SENSystemAlert : NSObject <SENSerializable>

@property (nonatomic, copy, nullable, readonly) NSString* localizedTitle;
@property (nonatomic, copy, readonly) NSString* localizedBody;
@property (nonatomic, assign, readonly) SENAlertCategory category;

@end

NS_ASSUME_NONNULL_END
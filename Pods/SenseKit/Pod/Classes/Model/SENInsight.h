
#import <Foundation/Foundation.h>

@class SENRemoteImage;

@interface SENInsight : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSDate* dateCreated;
@property (nonatomic, copy, readonly)   NSString* title;
@property (nonatomic, copy, readonly)   NSString* message;
@property (nonatomic, copy, readonly)   NSString* category;
@property (nonatomic, copy, readonly)   NSString* categoryName;
@property (nonatomic, copy, readonly)   NSString* infoPreview;
@property (nonatomic, strong, readonly) SENRemoteImage* remoteImage;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end

@interface SENInsightInfo : NSObject <NSCoding>

@property (nonatomic, assign, readonly) NSUInteger identifier;
@property (nonatomic, copy, readonly)   NSString* category;
@property (nonatomic, copy, readonly)   NSString* title;
@property (nonatomic, copy, readonly)   NSString* info;
@property (nonatomic, copy, readonly)   NSString* imageURI;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end

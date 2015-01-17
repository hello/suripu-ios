
#import <Foundation/Foundation.h>

@interface SENInsight : NSObject <NSCoding>

@property (nonatomic, copy) NSDate* dateCreated;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, copy) NSString* category;

- (instancetype)initWithDictionary:(NSDictionary*)dict;
- (BOOL)isGeneric;

@end

@interface SENInsightInfo : NSObject <NSCoding>

@property (nonatomic, assign, readonly) NSInteger identifier;
@property (nonatomic, copy, readonly)   NSString* category;
@property (nonatomic, copy, readonly)   NSString* title;
@property (nonatomic, copy, readonly)   NSString* info;
@property (nonatomic, copy, readonly)   NSString* imageURI;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end

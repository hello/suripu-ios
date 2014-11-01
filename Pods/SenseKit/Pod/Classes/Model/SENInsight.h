
#import <Foundation/Foundation.h>

@interface SENInsight : NSObject <NSCoding>

@property (nonatomic, strong) NSDate* dateCreated;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* message;

- (instancetype)initWithDictionary:(NSDictionary*)dict;
@end

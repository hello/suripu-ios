
#import <Foundation/Foundation.h>

@interface SENDevice : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString* identifier;
@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, strong, readonly) NSString* nickname;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, getter=isRecordingData) BOOL recordingData;

- (instancetype)initWithName:(NSString*)name nickname:(NSString*)nickname identifier:(NSString*)identifier;
@end

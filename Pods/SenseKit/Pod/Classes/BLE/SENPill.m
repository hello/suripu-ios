
#import "SENPill.h"

static NSString* const IDENTIFIER_KEY = @"identifier";
static NSString* const NICKNAME_KEY = @"nickname";
static NSString* const NAME_KEY = @"name";
static NSString* const RECORDING_KEY = @"recordingData";
static NSString* const DATE_KEY = @"date";

@implementation SENPill

- (instancetype)initWithName:(NSString*)name nickname:(NSString*)nickname identifier:(NSString*)identifier
{
    if (self = [super init]) {
        _identifier = identifier;
        _name = name;
        _nickname = nickname;
        _recordingData = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _identifier = [aDecoder decodeObjectForKey:IDENTIFIER_KEY];
        _name = [aDecoder decodeObjectForKey:NAME_KEY];
        _nickname = [aDecoder decodeObjectForKey:NICKNAME_KEY];
        _recordingData = [[aDecoder decodeObjectForKey:RECORDING_KEY] boolValue];
        _date = [aDecoder decodeObjectForKey:DATE_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.identifier forKey:IDENTIFIER_KEY];
    [aCoder encodeObject:self.name forKey:NAME_KEY];
    [aCoder encodeObject:self.nickname forKey:NICKNAME_KEY];
    [aCoder encodeObject:self.date forKey:DATE_KEY];
    [aCoder encodeObject:[NSNumber numberWithBool:[self isRecordingData]] forKey:RECORDING_KEY];
}

@end

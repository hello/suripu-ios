
#import <AFNetworking/AFHTTPSessionManager.h>
#import "SENAPIAccount.h"

NSString* const SENAPIAccountPropertyName = @"name";
NSString* const SENAPIAccountPropertyEmailAddress = @"email";
NSString* const SENAPIAccountPropertyPassword = @"password";
NSString* const SENAPIAccountPropertyGender = @"gender";
NSString* const SENAPIAccountPropertyHeight = @"height";
NSString* const SENAPIAccountPropertyWeight = @"weight";
NSString* const SENAPIAccountPropertyAge = @"age";
NSString* const SENAPIAccountPropertyTimezone = @"tz";
NSString* const SENAPIAccountPropertySignature = @"sig";

NSString* const SENAPIAccountCreateEndpoint = @"account";
NSString* const SENAPIAccountUpdateEndpoint = @"account/update";

@implementation SENAPIAccount

+ (void)createAccountWithName:(NSString*)name emailAddress:(NSString*)emailAddress password:(NSString*)password completion:(SENAPIDataBlock)completionBlock
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:5];

    if (password)
        params[SENAPIAccountPropertyPassword] = password;
    if (emailAddress)
        params[SENAPIAccountPropertyEmailAddress] = emailAddress;
    if (name)
        params[SENAPIAccountPropertyName] = name;
    params[SENAPIAccountPropertyTimezone] = @([[NSTimeZone localTimeZone] secondsFromGMT] * 1000);

    NSString* URLPath = [NSString stringWithFormat:@"%@?sig=%@", SENAPIAccountCreateEndpoint, @"xxx"];

    [[SENAPIClient HTTPSessionManager] POST:URLPath parameters:params success:^(NSURLSessionDataTask* task, id responseObject) {
        completionBlock(responseObject, task.error);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        completionBlock(nil, error);
    }];
}

+ (void)updateUserAccountWithAge:(NSNumber*)age gender:(SENAPIAccountGender)gender height:(NSNumber*)heightInCentimeters weight:(NSNumber*)weightInKilograms completion:(SENAPIDataBlock)completionBlock
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:4];
    params[SENAPIAccountPropertyGender] = [self formattedGenderForValue:gender];
    if (age)
        params[SENAPIAccountPropertyAge] = age;
    if (heightInCentimeters)
        params[SENAPIAccountPropertyHeight] = heightInCentimeters;
    if (weightInKilograms)
        params[SENAPIAccountPropertyWeight] = weightInKilograms;

    [[SENAPIClient HTTPSessionManager] POST:SENAPIAccountUpdateEndpoint parameters:params success:^(NSURLSessionDataTask* task, id responseObject) {
        completionBlock(responseObject, task.error);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        completionBlock(nil, error);
    }];
}

+ (NSString*)formattedGenderForValue:(SENAPIAccountGender)gender
{
    switch (gender) {
    case SENAPIAccountGenderFemale:
        return @"FEMALE";

    case SENAPIAccountGenderMale:
        return @"MALE";

    case SENAPIAccountGenderOther:
    default:
        return @"OTHER";
    }
}

@end

//
//  SENAnalyticsHEMAppAnalyticsSpec.m
//  Sense
//
//  Created by Jimmy Lu on 9/14/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SENAnalytics+HEMAppAnalytics.h"

SPEC_BEGIN(SENAnalyticsHEMAppAnalyticsSpec)

describe(@"SENAnalytics+HEMAppAnalytics", ^{
    
    describe(@"+trackSignUpOfNewAccount:", ^{
        
        context(@"account is provided", ^{
            
            __block SENAccount* account = nil;
            __block NSString* accountIdCreated = nil;
            __block NSDictionary* propertiesOnCreation = nil;
            
            beforeEach(^{
                [SENAnalytics stub:@selector(userWithId:didSignUpWithProperties:) withBlock:^id(NSArray *params) {
                    accountIdCreated = [params firstObject];
                    propertiesOnCreation = [params lastObject];
                    return nil;
                }];
                
                account = [[SENAccount alloc] initWithDictionary:@{@"firstname" : @"tester",
                                                                   @"lastname" : @"123",
                                                                   @"id" : @"1",
                                                                   @"email" : @"jimmy@sayhello.com"}];
                [SENAnalytics trackSignUpOfNewAccount:account];
            });
            
            afterEach(^{
                account = nil;
                accountIdCreated = nil;
                propertiesOnCreation = nil;
                [SENAnalytics clearStubs];
            });
            
            it(@"should track with properties", ^{
                [[propertiesOnCreation should] beNonNil];
            });
            
            it(@"should track with account full name", ^{
                NSString* name = propertiesOnCreation[@"name"];
                [[name should] equal:[account fullName]];
            });
            
            it(@"should track with the account id", ^{
                [[accountIdCreated should] equal:[account accountId]];
                NSString* accountIdProp = propertiesOnCreation[@"Account Id"];
                [[accountIdProp should] equal:[account accountId]];
            });
            
            it(@"should add Platform as a property", ^{
                NSString* platform = propertiesOnCreation[@"Platform"];
                [[platform should] equal:@"iOS"];
            });
            
            it(@"should add created date property", ^{
                id date = propertiesOnCreation[@"createdAt"];
                [[date should] beKindOfClass:[NSDate class]];
            });
            
            it(@"should add email property", ^{
                NSString* email = propertiesOnCreation[@"email"];
                [[email should] equal:[account email]];
            });
            
        });
        
    });
    
});

SPEC_END


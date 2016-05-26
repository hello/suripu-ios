//
//  HEMAccountServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 12/22/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <Kiwi/Kiwi.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import "HEMAccountService.h"

SPEC_BEGIN(HEMAccountServiceSpec)

describe(@"HEMAccountService", ^{
    
    describe(@"-refresh:", ^{
        
        __block HEMAccountService* service = nil;
        __block SENAccount* myAccount = nil;
        __block NSDictionary* myPreferences = nil;
        
        context(@"could not retrieve preferences", ^{
            
            beforeEach(^{
                [SENAPIPreferences stub:@selector(getPreferences:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAPIAccount stub:@selector(getAccountWithQuery:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block ([SENAccount new], nil);
                    return nil;
                }];
                
                service = [HEMAccountService new];
                [service refresh:^(SENAccount * _Nullable account, NSDictionary<NSNumber *,SENPreference *> * _Nullable preferences) {
                    myAccount = account;
                    myPreferences = preferences;
                }];
            });
            
            afterEach(^{
                [SENAPIPreferences clearStubs];
                [SENAPIAccount clearStubs];
                service = nil;
                myAccount = nil;
                myPreferences = nil;
            });
            
            it(@"should return an account", ^{
                [[expectFutureValue(myAccount) shouldEventually] beNonNil];
            });
            
            it(@"should not return preferences", ^{
                [[expectFutureValue(myPreferences) shouldEventually] beNil];
            });
            
            it(@"should not have set cached preferences", ^{
                [[expectFutureValue([service preferences]) shouldEventually] beNil];
            });
            
            it(@"should have set cached account", ^{
                [[expectFutureValue([service account]) shouldEventually] beNonNil];
            });
            
        });
        
        context(@"retrieved both account and preferences", ^{
            
            beforeEach(^{
                [SENAPIPreferences stub:@selector(getPreferences:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (@{}, nil);
                    return nil;
                }];
                
                [SENAPIAccount stub:@selector(getAccountWithQuery:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block ([SENAccount new], nil);
                    return nil;
                }];
                
                service = [HEMAccountService new];
                [service refresh:^(SENAccount * _Nullable account, NSDictionary<NSNumber *,SENPreference *> * _Nullable preferences) {
                    myAccount = account;
                    myPreferences = preferences;
                }];
            });
            
            afterEach(^{
                [SENAPIPreferences clearStubs];
                [SENAPIAccount clearStubs];
                service = nil;
                myAccount = nil;
                myPreferences = nil;
            });
            
            it(@"should return an account", ^{
                [[expectFutureValue(myAccount) shouldEventually] beNonNil];
            });
            
            it(@"should return preferences", ^{
                [[expectFutureValue(myPreferences) shouldEventually] beNonNil];
            });
            
            it(@"should have set cached preferences", ^{
                [[expectFutureValue([service preferences]) shouldEventually] beNonNil];
            });
            
            it(@"should have set cached account", ^{
                [[expectFutureValue([service account]) shouldEventually] beNonNil];
            });
            
        });
        
        context(@"could not retrieve account", ^{
            
            beforeEach(^{
                [SENAPIPreferences stub:@selector(getPreferences:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (@{}, nil);
                    return nil;
                }];
                
                [SENAPIAccount stub:@selector(getAccountWithQuery:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, [NSError errorWithDomain:@"t" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                service = [HEMAccountService new];
                [service refresh:^(SENAccount * _Nullable account, NSDictionary<NSNumber *,SENPreference *> * _Nullable preferences) {
                    myAccount = account;
                    myPreferences = preferences;
                }];
            });
            
            afterEach(^{
                [SENAPIPreferences clearStubs];
                [SENAPIAccount clearStubs];
                service = nil;
                myAccount = nil;
                myPreferences = nil;
            });
            
            it(@"should not return an account", ^{
                [[expectFutureValue(myAccount) shouldEventually] beNil];
            });
            
            it(@"should return preferences", ^{
                [[expectFutureValue(myPreferences) shouldEventually] beNonNil];
            });
            
            it(@"should have set cached preferences", ^{
                [[expectFutureValue([service preferences]) shouldEventually] beNonNil];
            });
            
            it(@"should not have set cached account", ^{
                [[expectFutureValue([service account]) shouldEventually] beNil];
            });
            
        });
        
    });
    
    describe(@"-isEnabled:", ^{
        
        __block HEMAccountService* service = nil;
        
        context(@"there are no preferenes", ^{
            
            beforeEach(^{
                service = [HEMAccountService new];
                [service stub:@selector(preferences) andReturn:@{}];
            });
            
            afterEach(^{
                service = nil;
            });
            
            it(@"should return NO", ^{
                BOOL enabled = [service isEnabled:SENPreferenceTypeEnhancedAudio];
                [[@(enabled) should] beNo];
            });
            
        });
        
        context(@"Enhanced audio is set to be on", ^{
            
            beforeEach(^{
                service = [HEMAccountService new];
                
                SENPreference* preference = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
                NSDictionary* preferences = @{@(SENPreferenceTypeEnhancedAudio) : preference};
                [service stub:@selector(preferences) andReturn:preferences];
            });
            
            afterEach(^{
                service = nil;
            });
            
            it(@"should return YES for enhanced audio", ^{
                BOOL enabled = [service isEnabled:SENPreferenceTypeEnhancedAudio];
                [[@(enabled) should] beYes];
            });
            
            it(@"should return NO for enhanced 24 hour time", ^{
                BOOL enabled = [service isEnabled:SENPreferenceTypeTime24];
                [[@(enabled) should] beNo];
            });
            
        });
        
        context(@"24 hour time is disabled", ^{
            
            beforeEach(^{
                service = [HEMAccountService new];
                
                SENPreference* preference = [[SENPreference alloc] initWithType:SENPreferenceTypeTime24 enable:NO];
                NSDictionary* preferences = @{@(SENPreferenceTypeTime24) : preference};
                [service stub:@selector(preferences) andReturn:preferences];
            });
            
            afterEach(^{
                service = nil;
            });
            
            it(@"should return NO for enhanced audio", ^{
                BOOL enabled = [service isEnabled:SENPreferenceTypeEnhancedAudio];
                [[@(enabled) should] beNo];
            });
            
            it(@"should return NO for enhanced 24 hour time", ^{
                BOOL enabled = [service isEnabled:SENPreferenceTypeTime24];
                [[@(enabled) should] beNo];
            });
            
        });
        
    });
    
    describe(@"-enablePreference:forType:completion:", ^{
        
        __block HEMAccountService* service = nil;
        __block NSError* serviceError = nil;
        __block BOOL calledBack = NO;
        
        context(@"enhanced audio enabled successfully", ^{
            
            beforeEach(^{
                [SENAPIPreferences stub:@selector(updatePreferencesWithCompletion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    SENPreference* pref = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
                    block (@{@(SENPreferenceTypeEnhancedAudio) : pref}, nil);
                    return nil;
                }];
                
                service = [HEMAccountService new];
                [service enablePreference:YES forType:SENPreferenceTypeEnhancedAudio completion:^(NSError * _Nullable error) {
                    serviceError = error;
                    calledBack = YES;
                }];
            });
            
            afterEach(^{
                service = nil;
                serviceError = nil;
                calledBack = NO;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return an error", ^{
                [[serviceError should] beNil];
            });
            
            it(@"should have enhanced audio cached and enabled", ^{
                BOOL enabled = [service isEnabled:SENPreferenceTypeEnhancedAudio];
                [[@(enabled) should] beYes];
            });
            
        });
        
    });
    
    describe(@"-updateBirthdate:completion:", ^{
        
        __block HEMAccountService* service = nil;
        __block NSError* serviceError = nil;
        __block BOOL calledBack = NO;
        __block NSString* birthdate = nil;
        
        context(@"successfully updated birthdate", ^{
            
            beforeEach(^{
                birthdate = @"2014-08-18";
                [SENAPIAccount stub:@selector(updateAccount:completionBlock:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    SENAccount* account = [SENAccount new];
                    [account setBirthdate:birthdate];
                    block (account, nil);
                    return nil;
                }];
                
                service = [HEMAccountService new];
                [service stub:@selector(account) andReturn:[SENAccount new]];
                [service updateBirthdate:birthdate completion:^(NSError * _Nullable error) {
                    calledBack = YES;
                    serviceError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                service = nil;
                serviceError = nil;
                calledBack = NO;
                birthdate = nil;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have returned an error", ^{
                [[serviceError should] beNil];
            });
            
            it(@"should have cached an account with correct birthdate", ^{
                SENAccount* account = [service account];
                [[[account birthdate] should] equal:birthdate];
            });
            
        });
        
    });
    
    describe(@"-updateGender:completion:", ^{
        
        __block HEMAccountService* service = nil;
        __block NSError* serviceError = nil;
        __block BOOL calledBack = NO;
        __block SENAccountGender gender = SENAccountGenderOther;
        
        context(@"successfully updated gender", ^{
            
            beforeEach(^{
                gender = SENAccountGenderMale;
                [SENAPIAccount stub:@selector(updateAccount:completionBlock:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    SENAccount* account = [SENAccount new];
                    [account setGender:gender];
                    block (account, nil);
                    return nil;
                }];
                
                service = [HEMAccountService new];
                [service stub:@selector(account) andReturn:[SENAccount new]];
                [service updateGender:gender completion:^(NSError * _Nullable error) {
                    calledBack = YES;
                    serviceError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                service = nil;
                serviceError = nil;
                calledBack = NO;
                gender = SENAccountGenderOther;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have returned an error", ^{
                [[serviceError should] beNil];
            });
            
            it(@"should have cached an account with correct gender", ^{
                SENAccount* account = [service account];
                [[@([account gender]) should] equal:@(gender)];
            });
            
        });
        
    });
    
    describe(@"-updateHeight:completion:", ^{
        
        __block HEMAccountService* service = nil;
        __block NSError* serviceError = nil;
        __block BOOL calledBack = NO;
        __block NSNumber* height = nil;
        
        context(@"successfully updated height", ^{
            
            beforeEach(^{
                height = @161;
                [SENAPIAccount stub:@selector(updateAccount:completionBlock:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    SENAccount* account = [SENAccount new];
                    [account setHeight:height];
                    block (account, nil);
                    return nil;
                }];
                
                service = [HEMAccountService new];
                [service stub:@selector(account) andReturn:[SENAccount new]];
                [service updateHeight:height completion:^(NSError * _Nullable error) {
                    calledBack = YES;
                    serviceError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                service = nil;
                serviceError = nil;
                calledBack = NO;
                height = nil;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have returned an error", ^{
                [[serviceError should] beNil];
            });
            
            it(@"should have cached an account with correct height", ^{
                SENAccount* account = [service account];
                [[[account height] should] equal:height];
            });
            
        });
        
    });
    
    describe(@"-updateWeight:completion:", ^{
        
        __block HEMAccountService* service = nil;
        __block NSError* serviceError = nil;
        __block BOOL calledBack = NO;
        __block NSNumber* weight = nil;
        
        context(@"successfully updated weight", ^{
            
            beforeEach(^{
                weight = @90;
                [SENAPIAccount stub:@selector(updateAccount:completionBlock:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    SENAccount* account = [SENAccount new];
                    [account setHeight:weight];
                    block (account, nil);
                    return nil;
                }];
                
                service = [HEMAccountService new];
                [service stub:@selector(account) andReturn:[SENAccount new]];
                [service updateWeight:weight completion:^(NSError * _Nullable error) {
                    calledBack = YES;
                    serviceError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                service = nil;
                serviceError = nil;
                calledBack = NO;
                weight = nil;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have returned an error", ^{
                [[serviceError should] beNil];
            });
            
            it(@"should have cached an account with correct weight", ^{
                SENAccount* account = [service account];
                [[[account weight] should] equal:weight];
            });
            
        });
        
    });
    
    describe(@"-updateName:completion:", ^{
        
        __block HEMAccountService* service = nil;
        __block NSError* serviceError = nil;
        __block BOOL calledBack = NO;
        __block NSString* fname = nil;
        __block NSString* lname = nil;
        
        context(@"successfully updated first and last namename", ^{
            
            beforeEach(^{
                fname = @"jimmy";
                lname = @"lu";
                [SENAPIAccount stub:@selector(updateAccount:completionBlock:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    SENAccount* account = [SENAccount new];
                    [account setFirstName:fname];
                    [account setLastName:fname];
                    block (account, nil);
                    return nil;
                }];
                
                service = [HEMAccountService new];
                [service stub:@selector(account) andReturn:[SENAccount new]];
                [service updateFirstName:fname lastName:lname completion:^(NSError * _Nullable error) {
                    calledBack = YES;
                    serviceError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                service = nil;
                serviceError = nil;
                calledBack = NO;
                fname = nil;
                lname = nil;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have returned an error", ^{
                [[serviceError should] beNil];
            });
            
            it(@"should have cached an account with correct name", ^{
                SENAccount* account = [service account];
                [[[account firstName] should] equal:fname];
                [[[account lastName] should] equal:lname];
            });
            
        });
        
    });
    
});

SPEC_END


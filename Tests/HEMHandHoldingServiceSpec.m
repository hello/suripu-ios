//
//  HEMHandHoldingServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 1/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENLocalPreferences.h>
#import "HEMHandHoldingService.h"

@interface HEMHandHoldingService()

@property (nonatomic, strong) NSMutableDictionary* tutorialRecordKeeper;

@end

SPEC_BEGIN(HEMHandHoldingServiceSpec)

describe(@"HEMHandHoldingService", ^{
    
    describe(@"-init", ^{
        
        context(@"upgrade from older version", ^{
            
            __block HEMHandHoldingService* service = nil;
            __block BOOL savedRecords = NO;
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(persistentPreferenceForKey:) andReturn:nil];
                
                [prefs stub:@selector(setPersistentPreference:forKey:) withBlock:^id(NSArray *params) {
                    savedRecords = YES;
                    return nil;
                }];
                
                service = [HEMHandHoldingService new];
            });
            
            afterEach(^{
                [[SENLocalPreferences sharedPreferences] clearStubs];
                service = nil;
                savedRecords = NO;
            });
            
            it(@"should create new dictionary of records", ^{
                [[[service tutorialRecordKeeper] should] beNonNil];
            });
            
            it(@"should have set the new records in local prefs", ^{
                [[@(savedRecords) should] beYes];
            });
            
        });
        
        context(@"records already created", ^{
            
            __block HEMHandHoldingService* service = nil;
            __block BOOL savedRecords = NO;
            __block NSMutableDictionary* records = nil;
            
            beforeEach(^{
                records = [@{@"test" : @1} mutableCopy];
                
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(persistentPreferenceForKey:) andReturn:records];
                
                [prefs stub:@selector(setPersistentPreference:forKey:) withBlock:^id(NSArray *params) {
                    savedRecords = YES;
                    return nil;
                }];
                
                service = [HEMHandHoldingService new];
            });
            
            afterEach(^{
                [[SENLocalPreferences sharedPreferences] clearStubs];
                service = nil;
                savedRecords = NO;
                records = nil;
            });
            
            it(@"should return saved records", ^{
                [[[service tutorialRecordKeeper] should] equal:records];
            });
            
            it(@"should not have set the records in local prefs again", ^{
                [[@(savedRecords) should] beNo];
            });
            
        });
        
    });
    
});

SPEC_END

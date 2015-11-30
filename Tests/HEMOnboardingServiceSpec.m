//
//  HEMOnboardingServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 7/17/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Kiwi/Kiwi.h>
#import <SenseKit/BLE.h>
#import <SenseKit/SENAuthorizationService.h>
#import "HEMOnboardingService.h"
#import "HEMOnboardingController.h"

@interface HEMOnboardingService()

- (void)startPollingSensorData;

@end

SPEC_BEGIN(HEMOnboardingServiceSpec)

describe(@"HEMOnboardingService", ^{
    
    __block HEMOnboardingService* service;
    
    beforeAll(^{
        service = [HEMOnboardingService sharedService];
    });
    
    describe(@"-isAuthorizedUser", ^{
        
        it(@"should return YES if user is authorized", ^{
            
            [SENAuthorizationService stub:@selector(isAuthorized) andReturn:[KWValue valueWithBool:YES]];
            BOOL authorized = [service isAuthorizedUser];
            [[@(authorized) should] equal:@(YES)];
            
        });
        
        it(@"should return NO if user is not authorized", ^{

            [SENAuthorizationService stub:@selector(isAuthorized) andReturn:[KWValue valueWithBool:NO]];
            BOOL authorized = [service isAuthorizedUser];
            [[@(authorized) should] equal:@(NO)];
            
        });
        
    });
    
    describe(@"-hasFinishedOnboarding", ^{
        
        context(@"authorized user", ^{
            
            beforeEach(^{
                [service stub:@selector(isAuthorizedUser)
                    andReturn:[KWValue valueWithBool:YES]];
            });
            
            afterEach(^{
                [service clearStubs];
            });
            
            it(@"should return YES if checkpoint is reset, but authorized", ^{
                
                [service stub:@selector(onboardingCheckpoint)
                    andReturn:[KWValue valueWithInteger:HEMOnboardingCheckpointStart]];
                
                BOOL finished = [service hasFinishedOnboarding];
                [[@(finished) should] equal:@(YES)];
                
            });
            
            it(@"should return YES if checkpoint indicates sense colors screen has been viewed", ^{
                
                [service stub:@selector(onboardingCheckpoint)
                    andReturn:[KWValue valueWithInteger:HEMOnboardingCheckpointSenseColorsViewed]];
                
                BOOL finished = [service hasFinishedOnboarding];
                [[@(finished) should] equal:@(YES)];
                
            });
            
            it(@"should return NO if checkpoint is post sense pairing", ^{
                
                [service stub:@selector(onboardingCheckpoint)
                    andReturn:[KWValue valueWithInteger:HEMOnboardingCheckpointSenseDone]];
                
                BOOL finished = [service hasFinishedOnboarding];
                [[@(finished) should] equal:@(NO)];
                
            });
            
        });
        
        context(@"unauthorized user", ^{
            
            beforeEach(^{
                [service stub:@selector(isAuthorizedUser)
                    andReturn:[KWValue valueWithBool:NO]];
            });
            
            afterEach(^{
                [service clearStubs];
            });
            
            it(@"should return NO even if somehow checkpoint shows pill pairing is done", ^{
                
                [service stub:@selector(onboardingCheckpoint)
                    andReturn:[KWValue valueWithInteger:HEMOnboardingCheckpointPillDone]];
                
                BOOL finished = [service hasFinishedOnboarding];
                [[@(finished) should] equal:@(NO)];
                
            });
            
        });
        
    });
    
    describe(@"-forceSensorDataUploadFromSense:", ^{
        
        beforeEach(^{
            SENSenseManager* fakeManager = [[SENSenseManager alloc] init];
            [service stub:@selector(currentSenseManager) andReturn:fakeManager];
            [fakeManager stub:@selector(forceDataUpload:) withBlock:^id(NSArray *params) {
                SENSenseCompletionBlock block = [params lastObject];
                block (nil, nil);
                return nil;
            }];
        });
        
        afterEach(^{
            [service clear];
            [service clearStubs];
        });
        
        context(@"user has not finished onboarding", ^{
            
            beforeEach(^{
                [service saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountDone];
            });
            
            afterEach(^{
                [service resetOnboardingCheckpoint];
            });
            
            it(@"should start polling for sensor data", ^{
                [[service should] receive:@selector(startPollingSensorData)];
                [service forceSensorDataUploadFromSense:nil];
            });
            
            it(@"should callback", ^{
                __block BOOL calledBack = NO;
                [service stub:@selector(startPollingSensorData)];
                [service forceSensorDataUploadFromSense:^(NSError *error) {
                    calledBack = YES;
                }];
                [[@(calledBack) should] equal:@(YES)];
            });
            
        });
        
        context(@"user has finished onboarding", ^{
            
            beforeEach(^{
                [service stub:@selector(isAuthorizedUser) andReturn:[KWValue valueWithBool:YES]];
                [service saveOnboardingCheckpoint:HEMOnboardingCheckpointSenseColorsViewed];
            });
            
            afterEach(^{
                [service resetOnboardingCheckpoint];
            });
            
            it(@"should not poll for sensor data", ^{
                [[service shouldNot] receive:@selector(startPollingSensorData)];
                [service forceSensorDataUploadFromSense:nil];
            });
            
            it(@"should callback", ^{
                __block BOOL calledBack = NO;
                [service stub:@selector(startPollingSensorData)];
                [service forceSensorDataUploadFromSense:^(NSError *error) {
                    calledBack = YES;
                }];
                [[@(calledBack) should] equal:@(YES)];
            });
            
        });
        
    });
    
});

SPEC_END

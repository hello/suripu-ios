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
            
            it(@"should return YES if checkpoint is post pill pairing", ^{
                
                [service stub:@selector(onboardingCheckpoint)
                    andReturn:[KWValue valueWithInteger:HEMOnboardingCheckpointPillDone]];
                
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
    
});

SPEC_END

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
    
    describe(@"-hasFinishedOnboarding", ^{
        
        context(@"authorized user", ^{
            
            beforeEach(^{
                [SENAuthorizationService stub:@selector(isAuthorized)
                                    andReturn:[KWValue valueWithBool:YES]];
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
            
            beforeAll(^{
                [SENAuthorizationService stub:@selector(isAuthorized)
                                    andReturn:[KWValue valueWithBool:NO]];
            });
            
            it(@"should return NO even if somehow checkpoint shows pill pairing is done", ^{
                
                [service stub:@selector(onboardingCheckpoint)
                    andReturn:[KWValue valueWithInteger:HEMOnboardingCheckpointPillDone]];
                
                BOOL finished = [service hasFinishedOnboarding];
                [[@(finished) should] equal:@(NO)];
                
            });
            
        });
        
    });
    
    describe(@"+onboardingControllerForCheckpoint", ^{
        
        context(@"unauthorized user", ^{
            
            beforeEach(^{
                [service stub:@selector(isAuthorizedUser)
                    andReturn:[KWValue valueWithBool:NO]];
            });
            
            afterEach(^{
                [service clearStubs];
            });
            
            it(@"should return the initial view controller in the flow", ^{
                
                HEMOnboardingCheckpoint check = HEMOnboardingCheckpointPillDone;
                UIViewController* controller = [HEMOnboardingController controllerForCheckpoint:check force:NO];
                
                UIStoryboard* onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding"
                                                                               bundle:[NSBundle mainBundle]];
                UIViewController* initialViewController = [onboardingStoryboard instantiateInitialViewController];
                
                [[[controller class] should] equal:[initialViewController class]];
                
            });
            
        });
        
        context(@"authorized user", ^{
            
            beforeEach(^{
                [service stub:@selector(isAuthorizedUser)
                    andReturn:[KWValue valueWithBool:YES]];
            });
            
            afterEach(^{
                [service clearStubs];
            });
            
            it(@"should force user back out when flag is set", ^{
                
                HEMOnboardingCheckpoint check = HEMOnboardingCheckpointPillDone;
                UIViewController* controller = [HEMOnboardingController controllerForCheckpoint:check force:YES];
                
                UIStoryboard* onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding"
                                                                               bundle:[NSBundle mainBundle]];
                UIViewController* initialViewController = [onboardingStoryboard instantiateInitialViewController];
                
                [[[controller class] should] equal:[initialViewController class]];
                
            });
            
            it(@"should return nil if onboarding is done", ^{
                
                HEMOnboardingCheckpoint check = HEMOnboardingCheckpointPillDone;
                UIViewController* controller = [HEMOnboardingController controllerForCheckpoint:check force:NO];
                [[controller should] beNil];
                
            });
            
            it(@"should return an onboarding controller after account created", ^{
                
                HEMOnboardingCheckpoint check = HEMOnboardingCheckpointAccountCreated;
                UIViewController* controller = [HEMOnboardingController controllerForCheckpoint:check force:NO];
                [[controller shouldNot] beNil];
                
            });
            
            it(@"should return an onboarding controller after demographics set", ^{
                
                HEMOnboardingCheckpoint check = HEMOnboardingCheckpointAccountDone;
                UIViewController* controller = [HEMOnboardingController controllerForCheckpoint:check force:NO];
                [[controller shouldNot] beNil];
                
            });
            
            it(@"should return an onboarding controller after sense paired", ^{
                
                HEMOnboardingCheckpoint check = HEMOnboardingCheckpointSenseDone;
                UIViewController* controller = [HEMOnboardingController controllerForCheckpoint:check force:NO];
                [[controller shouldNot] beNil];
                
            });
            
        });
        
    });
    
});

SPEC_END

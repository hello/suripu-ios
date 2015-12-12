//
//  HEMOnboardingControllerSpec.m
//  Sense
//
//  Created by Jimmy Lu on 7/20/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Kiwi/Kiwi.h>
#import "HEMOnboardingController.h"
#import "HEMOnboardingService.h"

SPEC_BEGIN(HEMOnboardingControllerSpec)

describe(@"+onboardingControllerForCheckpoint", ^{
    
    __block HEMOnboardingService* service = nil;
    
    beforeAll(^{
        service = [HEMOnboardingService sharedService];
    });
    
    context(@"unauthorized user", ^{
        
        beforeEach(^{
            [service stub:@selector(isAuthorizedUser)
                andReturn:[KWValue valueWithBool:NO]];
        });
        
        afterEach(^{
            [service clearStubs];
        });
        
        it(@"should return the initial view controller in the flow", ^{
            
            HEMOnboardingCheckpoint check = HEMOnboardingCheckpointPillFinished;
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
            
            HEMOnboardingCheckpoint check = HEMOnboardingCheckpointPillFinished;
            UIViewController* controller = [HEMOnboardingController controllerForCheckpoint:check force:YES];
            
            UIStoryboard* onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding"
                                                                           bundle:[NSBundle mainBundle]];
            UIViewController* initialViewController = [onboardingStoryboard instantiateInitialViewController];
            
            [[[controller class] should] equal:[initialViewController class]];
            
        });
        
        it(@"should return nil if onboarding is done", ^{
            
            HEMOnboardingCheckpoint check = HEMOnboardingCheckpointSenseColorsFinished;
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

SPEC_END


#import <Kiwi/Kiwi.h>
#import "HEMAlarm.h"

SPEC_BEGIN(HEMAlarmSpec)

describe(@"HEMAlarm", ^{

    describe(@"-initWithDictionary:", ^{
        __block HEMAlarm* alarm;
        
        NSDictionary* alarmValues = @{@"on": @YES, @"hour":@22, @"minute":@15, @"sound":@"Bells"};
        
        beforeEach(^{
            alarm = [[HEMAlarm alloc] initWithDictionary:alarmValues];
        });
        
        it(@"sets the activation state", ^{
            [[@([alarm isOn]) should] beTrue];
        });
        
        it(@"sets the hour", ^{
            [[@([alarm hour]) should] equal:alarmValues[@"hour"]];
        });
        
        it(@"sets the minute", ^{
            [[@([alarm minute]) should] equal:alarmValues[@"minute"]];
        });
        
        it(@"sets the sound", ^{
            [[[alarm soundName] should] equal:alarmValues[@"sound"]];
        });
    });
    
    describe(@"- incrementAlarmTimeByMinutes:", ^{
        
        __block HEMAlarm* alarm;
        
        beforeEach(^{
            alarm = [[HEMAlarm alloc] initWithDictionary:@{@"hour": @2, @"minute": @0}];
        });
       
        context(@"minutes do not roll over to a different hour", ^{
            
            beforeEach(^{
                [alarm incrementAlarmTimeByMinutes:40];
            });
            
            it(@"updates the number of minutes", ^{
                [[@([alarm minute]) should] equal:@40];
            });
        });
        
        context(@"minutes roll over to a differen hour", ^{
           
            beforeEach(^{
                [alarm incrementAlarmTimeByMinutes:130];
            });
            
            it(@"updates the number of minutes", ^{
                [[@([alarm minute]) should] equal:@10];
            });
            
            it(@"updates the number of hours", ^{
                [[@([alarm hour]) should] equal:@4];
            });
        });
        
        context(@"minutes and hours roll forward to a different day", ^{
            
            beforeEach(^{
                [alarm incrementAlarmTimeByMinutes:1430];
            });
            
            it(@"updates the number of minutes", ^{
                [[@([alarm minute]) should] equal:@50];
            });

            it(@"updates the number of hours", ^{
                [[@([alarm hour]) should] equal:@1];
            });
        });
        
        context(@"minutes and hours roll backward to a different day", ^{
            
            beforeEach(^{
                [alarm incrementAlarmTimeByMinutes:-130];
            });
            
            it(@"updates the number of minutes", ^{
                [[@([alarm minute]) should] equal:@50];
            });
            
            it(@"updates the number of hours", ^{
                [[@([alarm hour]) should] equal:@23];
            });
        });
        
        context(@"minutes roll backwards less than an hour", ^{
           
            beforeEach(^{
                [alarm incrementAlarmTimeByMinutes:-20];
            });
            
            it(@"updates the minutes", ^{
                [[@([alarm minute]) should] equal:@40];
            });
            
            it(@"updates the hour", ^{
                [[@([alarm hour]) should] equal:@1];
            });
        });
    });
});

SPEC_END

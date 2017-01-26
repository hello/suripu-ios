//
//  FontSpec.m
//  Sense
//
//  Created by Jimmy Lu on 1/26/17.
//  Copyright © 2017 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Sense-Swift.h"

SPEC_BEGIN(FontSpec)

describe(@"Font", ^{
    
    describe(@"+named:", ^{
        
        // this will verify both loading of fonts.json and something we expect
        // in the resource file
        context(@"contains font in file", ^{
            
            it(@"should contain h1", ^{
                UIFont* font = [Font namedWithName:@"h1"];
                [[font should] beKindOfClass:[UIFont class]];
            });
            
            it(@"should not equal to default font", ^{
                UIFont* font = [Font namedWithName:@"h1"];
                UIFont* sysFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                [[font shouldNot] equal:sysFont];
            });
            
        });
        
        context(@"some random font name", ^{
            
            it(@"should return default system font", ^{
                UIFont* font = [Font namedWithName:@"randomTestFont"];
                UIFont* sysFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                [[font should] equal:sysFont];
            });
            
        });
        
    });
    
});

SPEC_END

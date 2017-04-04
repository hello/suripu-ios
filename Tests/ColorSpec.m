//
//  ColorSpec.m
//  Sense
//
//  Created by Jimmy Lu on 1/26/17.
//  Copyright © 2017 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Sense-Swift.h"

SPEC_BEGIN(ColorSpec)

describe(@"Color", ^{
    
    describe(@"+named:", ^{
        
        // this will verify both loading of colors.json and something we expect
        // in the resource file
        context(@"contains color in file", ^{
            
            it(@"should contain grey.1", ^{
                UIColor* color = [Color namedWithName:@"grey.1"];
                [[color should] beKindOfClass:[UIColor class]];
            });
            
            it(@"should not equal to default black", ^{
                UIColor* color = [Color namedWithName:@"blue.1"];
                [[color shouldNot] equal:[UIColor blackColor]];
            });
            
        });
        
        context(@"some random color name", ^{
            
            it(@"should return default system font", ^{
                UIColor* color = [Color namedWithName:@"rainbow"];
                [[color should] equal:[UIColor blackColor]];
            });
            
        });
        
    });
    
});

SPEC_END

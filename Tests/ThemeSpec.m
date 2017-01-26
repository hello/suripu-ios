//
//  ThemeSpec.m
//  Sense
//
//  Created by Jimmy Lu on 1/26/17.
//  Copyright © 2017 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Sense-Swift.h"

SPEC_BEGIN(ThemeSpec)

describe(@"Theme", ^{
    
    describe(@"-valueWithStyle:name:", ^{
        
        context(@"default theme", ^{
            
            __block Theme* theme = nil;
            
            beforeEach(^{
                theme = [Theme new];
            });
            
            afterEach(^{
                theme = nil;
            });
            
            it(@"should have navigation title color", ^{
                NSString* key = [theme keyWithProperty:ThemePropertyNavTitleColor];
                id color = [theme valueWithStyle:nil name:key];
                [[color should] beKindOfClass:[UIColor class]];
            });
            
            it(@"should have navigation title font", ^{
                NSString* key = [theme keyWithProperty:ThemePropertyNavTitleFont];
                id font = [theme valueWithStyle:nil name:key];
                [[font should] beKindOfClass:[UIFont class]];
            });
            
        });
        
        context(@"night theme", ^{
            
            __block Theme* theme = nil;
            __block Theme* night = nil;
            
            beforeEach(^{
                theme = [Theme new];
                night = [[Theme alloc] initWithName:@"nightTheme"];
            });
            
            afterEach(^{
                theme = nil;
                night = nil;
            });
            
            it(@"should not match default navigation title color", ^{
                NSString* key = [theme keyWithProperty:ThemePropertyNavTitleColor];
                id defaultColor = [theme valueWithStyle:nil name:key];
                id nightColor = [night valueWithStyle:nil name:key];
                [[nightColor should] beKindOfClass:[UIColor class]];
                [[nightColor shouldNot] equal:defaultColor];
            });
            
            it(@"should match default navigation title font", ^{
                NSString* key = [theme keyWithProperty:ThemePropertyNavTitleFont];
                id defaultFont = [theme valueWithStyle:nil name:key];
                id nightFont = [night valueWithStyle:nil name:key];
                [[nightFont should] beKindOfClass:[UIFont class]];
                [[nightFont should] equal:defaultFont];
            });
            
        });
        
    });
    
});

SPEC_END

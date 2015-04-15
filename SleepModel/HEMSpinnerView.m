//
//  HEMSlotSpinnerView.m
//  Sense
//
//  Created by Jimmy Lu on 4/13/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMSpinnerView.h"
#import "HEMAnimationUtils.h"

static CGFloat const HEMSpinnerDefaultDamping = 1.0f;
static CGFloat const HEMSpinnerEndDamping = 0.6f;
static CGFloat const HEMSpinnerDefaultDuration = 0.05f;
static CGFloat const HEMSpinnerDefaultInitialVelocity = 2.0f;

@interface HEMSpinnerView()

@property (nonatomic, strong) UIFont* font;
@property (nonatomic, copy)   NSArray* items;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, weak)   UILabel* offScreenLabel;
@property (nonatomic, weak)   UILabel* onScreenLabel;

@end

@implementation HEMSpinnerView

+ (CGRect)frameWithItems:(NSArray*)items andFont:(UIFont*)font {
    CGRect frame = CGRectZero;
    
    for (NSString* item in items) {
        CGSize size = [item sizeWithAttributes:@{NSFontAttributeName : font}];
        frame.size.width = MAX(CGRectGetWidth(frame), ceilf(size.width));
        frame.size.height = MAX(CGRectGetHeight(frame), ceilf(size.height));
    }
    
    return frame;
}

- (instancetype)initWithItems:(NSArray*)items
                         font:(UIFont*)font
                        color:(UIColor*)color {
    
    self = [super initWithFrame:[[self class] frameWithItems:items andFont:font]];
    if (self) {
        _items = [items copy];
        _font = font;
        _color = color;
        [self configureDefaultProperties];
        [self configureSpinner];
    }
    
    return self;
}

- (void)configureDefaultProperties {
    [self setBackgroundColor:[UIColor clearColor]];
    [self setClipsToBounds:NO];
}

- (void)configureSpinner {
    NSInteger itemCount = [[self items] count];
    
    if (itemCount == 0) {
        return;
    }
    
    NSInteger index = 0;
    UILabel* onScreenLabel = [self labelWithText:[self items][index] withTag:index];
    [self addSubview:onScreenLabel];
    [self setOnScreenLabel:onScreenLabel];
    
    if (itemCount > 1) {
        index = 1;
        UILabel* offScreenLabel = [self labelWithText:[self items][index] withTag:index];
        CGRect offScreenFrame = [offScreenLabel frame];
        offScreenFrame.origin.y = -CGRectGetHeight([self bounds]);
        [offScreenLabel setFrame:offScreenFrame];
        [self addSubview:offScreenLabel];
        [self setOffScreenLabel:offScreenLabel];
    }

}

- (UILabel*)labelWithText:(NSString*)text withTag:(NSInteger)tag {
    UILabel* label = [[UILabel alloc] initWithFrame:[self bounds]];
    [label setFont:[self font]];
    [label setTextColor:[self color]];
    [label setText:text];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTag:tag];
    return label;
}

#pragma mark - Animations

- (void)spinTo:(NSString*)targetItem
    completion:(void(^)(BOOL finished))completion {
    
    NSUInteger itemCount = [[self items] count];
    CGFloat slotHeight = CGRectGetHeight([self bounds]);
    CGFloat damping = HEMSpinnerDefaultDamping;
    CGFloat duration = HEMSpinnerDefaultDuration;
    CGFloat velocity = HEMSpinnerDefaultInitialVelocity;
    BOOL willFinish = [[[self offScreenLabel] text] isEqualToString:targetItem];
    
    if (willFinish) {
        damping = HEMSpinnerEndDamping;
        duration = (1 + damping) / velocity;
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0f
         usingSpringWithDamping:damping
          initialSpringVelocity:velocity
                        options:UIViewAnimationOptionBeginFromCurrentState
                                |UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self move:[self onScreenLabel] byY:slotHeight];
                         [self move:[self offScreenLabel] byY:slotHeight];
                     }
                     completion:^(BOOL finished) {
                         if (willFinish) {
                             if (completion) {
                                 completion (finished);
                             }
                         } else {
                             NSUInteger nextIndex = ([[self offScreenLabel] tag] + 1) % itemCount;
                             NSString* nextTargetItem = [self items][nextIndex];
                             
                             UILabel* tempLabel = [self onScreenLabel];
                             [self setOnScreenLabel:[self offScreenLabel]];
                             [self setOffScreenLabel:tempLabel];
                             
                             [[self offScreenLabel] setText:nextTargetItem];
                             [[self offScreenLabel] setTag:nextIndex];
                             [self move:[self offScreenLabel] byY:-2 * slotHeight];
                             
                             [self spinTo:targetItem completion:completion];
                         }
                     }];
    
}

- (void)move:(UIView*)view byY:(CGFloat)y {
    CGRect frame = [view frame];
    frame.origin.y += y;
    [view setFrame:frame];
}

@end

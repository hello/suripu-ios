//
//  HEMSleepQuestionAlertView.m
//  Sense
//
//  Created by Jimmy Lu on 9/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMInfoAlertView.h"
#import "HelloStyleKit.h"

static CGFloat const kHEMSleepQuestionPadding = 12.0f;
static CGFloat const kHEMSleepQuestionHeight = 64.0f;
static CGFloat const kHEMSleepQuestionAnimDuration = 0.4f;

@interface HEMInfoAlertView()

@property (nonatomic, weak) UITapGestureRecognizer* tap;

@end

@implementation HEMInfoAlertView

- (id)initWithInfo:(NSString*)info {
    // TODO: questionIcon is a placehold icon
    return [self initWithInfo:info andIcon:[UIImage imageNamed:@"questionIcon.png"]];
}

- (id)initWithInfo:(NSString*)info andIcon:(UIImage*)icon {
    UIScreen* mainScreen = [UIScreen mainScreen];
    CGFloat fullHeight = kHEMSleepQuestionHeight + kHEMSleepQuestionPadding;
    CGRect defaultFrame = {0.0f, 0.0f, CGRectGetWidth([mainScreen bounds]), fullHeight};
    self = [super initWithFrame:defaultFrame];
    if (self) {
        [self setupInfo:info withIcon:icon];
        [self addTapGesture];
    }
    return self;
}

- (void)setupInfo:(NSString*)info withIcon:(UIImage*)icon {
    [self setBackgroundColor:[UIColor colorWithRed:83.0f/255.0f green:142.0f/255.0f blue:255.0f alpha:0.9f]];

    CGRect iconFrame = {
        kHEMSleepQuestionPadding,
        ceilf((kHEMSleepQuestionHeight-icon.size.height)/2),
        icon.size.width,
        icon.size.height
    };
    UIImageView* iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    [iconView setImage:icon];
    [self addSubview:iconView];
    
    CGFloat labelX = CGRectGetMaxX(iconFrame)+kHEMSleepQuestionPadding;
    CGRect labelFrame = {
        labelX,
        0.0f,
        CGRectGetWidth([self bounds])-labelX-kHEMSleepQuestionPadding,
        kHEMSleepQuestionHeight
    };
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setText:info];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
    [label setTextColor:[UIColor whiteColor]];
    [label setNumberOfLines:2];
    [self addSubview:label];

}

- (void)addTapGesture {
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] init];
    [self setTap:tapGesture];
    [self addGestureRecognizer:[self tap]];
}

- (void)addTarget:(id)target action:(SEL)action {
    [[self tap] addTarget:target action:action];
}

- (void)showInView:(UIView*)view animated:(BOOL)animated completion:(void(^)(void))completion {
    // add the view below the current view's bounds, then slide up
    CGFloat bHeight = CGRectGetHeight([view bounds]);
    CGRect myFrame = [self frame];
    myFrame.origin.y = bHeight;
    [self setFrame:myFrame];
    
    [view addSubview:self];
    
    [UIView animateWithDuration:animated?kHEMSleepQuestionAnimDuration:0.0f
                          delay:0.0f
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect myFrame = [self frame];
                         myFrame.origin.y = bHeight - kHEMSleepQuestionHeight;
                         [self setFrame:myFrame];
                     }
                     completion:^(BOOL finished) {
                         if (completion) completion ();
                     }];
}

- (void)dismiss:(BOOL)animated completion:(void(^)(void))completion {
    CGFloat bHeight = CGRectGetHeight([[self superview] bounds]);
    
    [UIView animateWithDuration:animated?kHEMSleepQuestionAnimDuration:0.0f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect myFrame = [self frame];
                         myFrame.origin.y = bHeight;
                         [self setFrame:myFrame];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         if (completion) completion ();
                     }];
}

@end

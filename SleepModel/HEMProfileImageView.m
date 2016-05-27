//
//  HEMProfileImageView.m
//  Sense
//
//  Created by Jimmy Lu on 5/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMProfileImageView.h"
#import "HEMStyle.h"

static CGFloat const HEMProfileImageViewAnimeDuration = 0.25f;
static CGFloat const HEMProfileImageLoaderSize = 20.0f;

@interface HEMProfileImageView()

@property (nonatomic, weak) UIView* loadingView;

@end

@implementation HEMProfileImageView

- (void)awakeFromNib {
    [self configureDefaults];
    [self addLoadingView];
    [self applyCircleMask];
}

- (void)addLoadingView {
    UIView* container = [[UIView alloc] initWithFrame:[self bounds]];
    [container setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [container setBackgroundColor:[[UIColor grey6] colorWithAlphaComponent:0.7f]];
    [container setAlpha:0.0f];
    
    [self addSubview:container];
    [self setLoadingView:container];
}

- (void)configureDefaults {
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setIndicateActivity:YES];
}

- (void)applyCircleMask {
    CGFloat radius = CGRectGetHeight([self bounds]) / 2.0f;
    UIBezierPath* rectPath = [UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:0.0f];
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:radius];
    [rectPath appendPath:circlePath];
    [rectPath setUsesEvenOddFillRule:YES];
    
    CAShapeLayer* mask = [CAShapeLayer layer];
    [mask setPath:[rectPath CGPath]];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor whiteColor] CGColor]];
    
    [[self layer] addSublayer:mask];
}

- (void)clearPhoto {
    [self setImageWithURL:nil];
    [self resetState];
}

- (BOOL)showingProfilePhoto {
    return [self image] && ![[self image] isEqual:[UIImage imageNamed:@"defaultAvatar"]];
}

- (void)resetState {
    [self setImage:[UIImage imageNamed:@"defaultAvatar"]];
    [self cancelImageDownload];
}

- (void)showLoading:(BOOL)show completion:(void(^)(void))completion {
    if (show) {
        [[self loadDelegate] willLoadImageIn:self];
    }
    
    [UIView animateWithDuration:HEMProfileImageViewAnimeDuration animations:^{
        [[self loadingView] setAlpha:show];
    } completion:^(BOOL finished) {
        [[self loadDelegate] didFinishLoadingIn:self];
        if (completion) {
            completion ();
        }
    }];
}

- (void)downloadAndLoadImageFrom:(NSURLRequest*)request
                      completion:(HEMURLImageCallback)completion {
    __weak typeof(self) weakSelf = self;
    [self showLoading:YES completion:^{
        [super downloadAndLoadImageFrom:request completion:^(UIImage* image, NSString* url, NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf showLoading:NO completion:nil];
        }];
    }];
}

@end

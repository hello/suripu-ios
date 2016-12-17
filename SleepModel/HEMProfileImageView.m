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

@interface HEMProfileImageView()

@property (nonatomic, weak) UIView* dimmedOverlayView;
@property (nonatomic, weak) UIImageView* errorView;

@end

@implementation HEMProfileImageView

- (void)awakeFromNib {
    [super awakeFromNib];
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
    [self setDimmedOverlayView:container];
    [self addErrorView];
}

- (void)configureDefaults {
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setIndicateActivity:YES];
}

- (void)applyCircleMask {
    // make the rect slightly bigger than the bounds to prevent the image from
    // flashing slightly when loaded on the sides
    CGRect rect = CGRectInset([self bounds], -2.0f, -2.0f);
    CGFloat radius = CGRectGetHeight([self bounds]) / 2.0f;
    UIBezierPath* rectPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:0.0f];
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

- (void)addErrorView {
    UIImage* warningIcon = [UIImage imageNamed:@"warningIconWhite"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:warningIcon];
    [imageView setContentMode:UIViewContentModeCenter];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [imageView setFrame:[[self dimmedOverlayView] bounds]];
    [imageView setHidden:YES];
    [[self dimmedOverlayView] addSubview:imageView];
    [self setErrorView:imageView];
}

- (void)showDimmedOverlay:(BOOL)show completion:(void(^)(void))completion {
    if ((show && [[self dimmedOverlayView] alpha] > 0.999f)
        || (!show && [[self dimmedOverlayView] alpha] < 0.001f)) { // already in current state
        if (completion) {
            completion ();
        }
        return;
    }
    
    if (show) {
        [[self loadDelegate] willLoadImageIn:self];
    }
    
    [UIView animateWithDuration:HEMProfileImageViewAnimeDuration animations:^{
        [[self dimmedOverlayView] setAlpha:show];
    } completion:^(BOOL finished) {
        [[self loadDelegate] didFinishLoadingIn:self];
        if (completion) {
            completion ();
        }
    }];
}

- (void)downloadAndLoadImageFrom:(NSURLRequest*)request
                      completion:(HEMURLImageCallback)completion {
    [[self errorView] setHidden:YES];
    
    __weak typeof(self) weakSelf = self;
    [self showDimmedOverlay:YES completion:^{
        [super downloadAndLoadImageFrom:request completion:^(UIImage* image, NSString* url, NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!error) {
                [strongSelf showDimmedOverlay:NO completion:nil];
            }
            
            [[strongSelf errorView] setHidden:!error];
            
            if (completion) {
                completion (image, url, error);
            }
        }];
    }];
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    [self showDimmedOverlay:NO completion:nil];
    [[self errorView] setHidden:YES];
}

- (void)showError {
    [self showDimmedOverlay:YES completion:nil];
    [[self errorView] setHidden:NO];
}

@end

//
//  HEMTutorialViewController.m
//  Sense
//
//  Created by Jimmy Lu on 6/8/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTutorialViewController.h"
#import "HEMTutorialDataSource.h"
#import "HEMTutorialContent.h"
#import "HEMRootViewController.h"

static CGFloat const HEMTutorialContentHorzPadding = 20.0f;
static CGFloat const HEMTutorialContentMinScale = 0.9f;
static CGFloat const HEMTutorialContentCornerRadius = 3.0f;
static CGFloat const HEMTutorialContentNextScreenOpacity = 0.7f;
static CGFloat const HEMTutorialParallaxCoefficientBase = 3.0f;
static CGFloat const HEMTutorialParallaxOffscreenCoefficient = 0.07f;
static CGFloat const HEMTutorialContentDisplayDelay = 0.2f;
static CGFloat const HEMTutorialContentAnimDuration = 0.5f;
static CGFloat const HEMTutorialAnimDamping = 0.6f;

@interface HEMTutorialViewController () <UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentContainerView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *fakeBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeButtonBottomConstraint;

@property (strong, nonatomic) NSMutableArray* tutorialScreens;
// hold on to data sources as they are weak when assigned to collection views
@property (strong, nonatomic) NSMutableArray* tutorialDataSources;
@property (assign, nonatomic) CGFloat previousScrollOffsetX;
@property (assign, nonatomic) UIView* focusedScreen;
@property (assign, nonatomic) CGFloat closeButtonInitialButtonConstraint;
@property (assign, nonatomic, getter=didManuallyHideStatusBar) BOOL manuallyHidStatusBar;

@end

@implementation HEMTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self fakeBackgroundView] setImage:[self unblurredBackgroundImage]];
    [[self backgroundView] setImage:[self backgroundImage]];
    [self configureControls];
}

- (void)configureControls {
    [self setCloseButtonInitialButtonConstraint:[[self closeButtonBottomConstraint] constant]];
    
    NSInteger tutorialCount = [[self tutorials] count];
    if (tutorialCount <= 1) {
        [[self pageControl] setAlpha:0.0f];
    } else {
        [[self pageControl] setNumberOfPages:tutorialCount];
        [[self pageControl] setUserInteractionEnabled:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    HEMRootViewController* root = [HEMRootViewController rootViewControllerForKeyWindow];
    if (![root isStatusBarHidden]) {
        [root hideStatusBar];
        [self setManuallyHidStatusBar:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.25f animations:^{
        self.fakeBackgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        self.fakeBackgroundView.hidden = YES;
    }];
    if ([[self tutorialScreens] count] == 0) {
        [self addAndDisplayContent];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self didManuallyHideStatusBar]) {
        HEMRootViewController* root = [HEMRootViewController rootViewControllerForKeyWindow];
        [root showStatusBar];
    }
}

- (void)addAndDisplayContent {
    [self setTutorialScreens:[[NSMutableArray alloc] init]];
    [self setTutorialDataSources:[[NSMutableArray alloc] init]];
    
    CGFloat fullWidth = CGRectGetWidth([[self contentContainerView] bounds]);
    CGFloat animationOffset = fullWidth;
    
    // move all sreens offscreen by fullWidth, then animate it back in
    CGRect contentFrame = CGRectZero;
    contentFrame.origin.x = animationOffset + HEMTutorialContentHorzPadding;
    contentFrame.size.width = fullWidth - (2*HEMTutorialContentHorzPadding);
    contentFrame.size.height = CGRectGetHeight([[self contentContainerView] bounds]);
    
    NSInteger index = 0;
    for (HEMTutorialContent* content in [self tutorials]) {
        UICollectionView* screen = [self tutorialScreenWithFrame:contentFrame tag:index];
        
        if ([[self tutorialScreens] count] > 0) {
            CGFloat scale = HEMTutorialContentMinScale;
            [screen setTransform:CGAffineTransformMakeScale(scale, scale)];
            [screen setAlpha:HEMTutorialContentNextScreenOpacity];
        }
        
        HEMTutorialDataSource* dataSource = [[HEMTutorialDataSource alloc] initWithContent:content
                                                                         forCollectionView:screen];
        [screen setDataSource:dataSource];
        
        [[self tutorialDataSources] addObject:dataSource];
        [[self tutorialScreens] addObject:screen];
        [[self contentContainerView] insertSubview:screen atIndex:0];
        
        contentFrame.origin.x = CGRectGetMaxX(contentFrame) - HEMTutorialContentHorzPadding;
        index++;
    }
    
    [self updateContentSize];
    
    [self animateContentAtIndex:0 fromOffset:animationOffset completion:^{
        if ([[self tutorials] count] <= 1) {
            [UIView animateWithDuration:HEMTutorialContentAnimDuration animations:^{
                [self swapPageControlAndCloseButtonWithPercentage:1.0f];
                [[self closeButton] layoutIfNeeded];
            }];
        }
    }];
}

- (UICollectionView*)tutorialScreenWithFrame:(CGRect)frame tag:(NSInteger)tag {
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UICollectionView* screen = [[UICollectionView alloc] initWithFrame:frame
                                                  collectionViewLayout:layout];
    
    [screen setBackgroundColor:[UIColor whiteColor]];
    [screen setDelegate:self];
    [screen setTag:tag];
    [[screen layer] setCornerRadius:HEMTutorialContentCornerRadius];
    
    return screen;
}

- (void)updateContentSize {
    CGFloat count = [[self tutorials] count];
    CGSize contentSize = [[self contentContainerView] contentSize];
    contentSize.width = CGRectGetWidth([[self contentContainerView] bounds]) * count;
    [[self contentContainerView] setContentSize:contentSize];
}

- (void)animateContentAtIndex:(NSInteger)index
                   fromOffset:(CGFloat)offset
                   completion:(void(^)(void))completion {
    
    if (index >= [[self tutorialScreens] count]) {
        [[self contentContainerView] setScrollEnabled:YES];
        if (completion) {
            completion ();
        }
        return;
    }
    
    [[self contentContainerView] setScrollEnabled:NO];
    
    CGFloat duration = HEMTutorialContentAnimDuration * (1 + HEMTutorialAnimDamping);
    [UIView animateWithDuration:duration
                          delay:HEMTutorialContentDisplayDelay
         usingSpringWithDamping:HEMTutorialAnimDamping
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         UIView* screen = [self tutorialScreens][index];
                         CGRect frame = [screen frame];
                         frame.origin.x -= offset;
                         [screen setFrame:frame];
                     }
                     completion:nil];
    
    NSTimeInterval delay = HEMTutorialContentDisplayDelay;
    int64_t delayInSecs = delay * NSEC_PER_SEC;
    dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^{
        [self animateContentAtIndex:index + 1 fromOffset:offset completion:completion];
    });

}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    HEMTutorialDataSource* dataSource = [self tutorialDataSources][[collectionView tag]];
    return [dataSource sizeForContentAtIndexPath:indexPath];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    HEMTutorialDataSource* dataSource = [self tutorialDataSources][[collectionView tag]];
    return [dataSource contentSpacingAtSection:section];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    HEMTutorialDataSource* dataSource = [self tutorialDataSources][[collectionView tag]];
    return [dataSource contentInsetAtSection:section];
}

#pragma mark - UIScrollViewDelegate

- (CGFloat)parallaxCoefficientForScreen:(NSUInteger)screenNumber {
    CGFloat base = HEMTutorialParallaxCoefficientBase;
    CGFloat off = HEMTutorialParallaxOffscreenCoefficient;
    CGFloat pad = HEMTutorialContentHorzPadding;
    return (base + (screenNumber > 1 ? screenNumber * off : 0.0f)) * pad;
}

- (void)scrollContent {
    UIScrollView* scrollView = [self contentContainerView];
    CGFloat offsetX = [scrollView contentOffset].x;
    if (offsetX < 0) {
        return;
    }

    CGFloat padding = HEMTutorialContentHorzPadding;
    CGFloat scrollWidth = CGRectGetWidth([scrollView bounds]);
    CGFloat fullTutorialScreenWidth = scrollWidth - (2 * padding);
    CGFloat previousMaxX = 0.0f;
    
    for (UICollectionView* screen in [self tutorialScreens]) {
        CGFloat screenX = CGRectGetMinX([screen frame]);
        CGFloat diff = screenX - offsetX;
        
        if (CGRectIntersectsRect([scrollView bounds], [screen frame])) { // onscreen tutorials

            if (diff < fullTutorialScreenWidth && diff > padding) {
                CGFloat distanceToFull = MIN(diff - padding, fullTutorialScreenWidth);
                CGFloat fullnessPercentage = fabs(1 - (distanceToFull / fullTutorialScreenWidth));
                
                CGFloat scaleToAdd = (1 - HEMTutorialContentMinScale) * fullnessPercentage;
                CGFloat adjustedScale = MIN(HEMTutorialContentMinScale + scaleToAdd, 1.0f);
                CGFloat alphaToAdd = (1 - HEMTutorialContentNextScreenOpacity) * fullnessPercentage;
                CGFloat adjustedAlpha = MIN(HEMTutorialContentNextScreenOpacity + alphaToAdd, 1.0f);
                
                CGFloat coefficient = [self parallaxCoefficientForScreen:[screen tag]];
                CGFloat adjustedX = coefficient * fullnessPercentage * adjustedScale;
                
                CGAffineTransform scaleXForm = CGAffineTransformMakeScale(adjustedScale, adjustedScale);
                CGAffineTransform transXForm = CGAffineTransformMakeTranslation(adjustedX, 0.0f);
                CGAffineTransform combinedXForm = CGAffineTransformConcat(scaleXForm, transXForm);
                
                [screen setAlpha:adjustedAlpha];
                [screen setTransform:combinedXForm];
                
                if ([screen tag] == [[self tutorialScreens] count] - 1) {
                    [self swapPageControlAndCloseButtonWithPercentage:fullnessPercentage];
                }
            }
            
        } else if (diff > 0) { // offscreen tutorials
            CGRect notVisibleScreenFrame = [screen frame];
            notVisibleScreenFrame.origin.x = previousMaxX;
            [screen setFrame:notVisibleScreenFrame];
        }
        
        previousMaxX = CGRectGetMaxX([screen frame]);
    }

}

- (void)swapPageControlAndCloseButtonWithPercentage:(CGFloat)percentage {
    [[self pageControl] setAlpha:1.0f - percentage];
    
    CGFloat bottomConstant = [self closeButtonInitialButtonConstraint];
    CGFloat distance = fabs(bottomConstant) * 2;
    CGFloat adjustedConstant = distance * percentage;
    [[self closeButtonBottomConstraint] setConstant:bottomConstant + adjustedConstant];
}

- (void)updatePageControl {
    CGFloat contentX = [[self contentContainerView] contentOffset].x;
    CGFloat scrollWidth = CGRectGetWidth([[self contentContainerView] bounds]);
    NSInteger pageNumber = contentX / scrollWidth;
    [[self pageControl] setCurrentPage:pageNumber];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == [self contentContainerView]) {
        [self scrollContent];
        [self updatePageControl];
        [self setPreviousScrollOffsetX:[scrollView contentOffset].x];
    }
}

#pragma mark - Actions

- (IBAction)close:(id)sender {
    [[self fakeBackgroundView] setHidden:NO];
    [UIView animateWithDuration:0.25f animations:^{
        [[self fakeBackgroundView] setAlpha:1.f];
        [[self contentContainerView] setAlpha:0];
        [[self closeButton] setAlpha:0];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

@end

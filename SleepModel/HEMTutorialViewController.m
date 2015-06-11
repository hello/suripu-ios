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

static CGFloat const HEMTutorialContentHorzPadding = 20.0f;
static CGFloat const HEMTutorialContentMinScale = 0.9f;
static CGFloat const HEMTutorialContentCornerRadius = 3.0f;
static CGFloat const HEMTutorialContentNextScreenOpacity = 0.7f;

@interface HEMTutorialViewController () <UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentContainerView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@property (strong, nonatomic) NSMutableArray* tutorialScreens;
// hold on to data sources as they are weak when assigned to collection views
@property (strong, nonatomic) NSMutableArray* tutorialDataSources;
@property (assign, nonatomic) CGFloat previousScrollOffsetX;
@property (assign, nonatomic) UIView* focusedScreen;

@end

@implementation HEMTutorialViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([[self tutorialScreens] count] == 0) {
        [self configureContent];
    }
}

- (void)configureContent {
    NSInteger tutorialCount = [[self tutorials] count];
    [[self backgroundView] setImage:[self backgroundImage]];
    [[self pageControl] setNumberOfPages:tutorialCount];
    [[self pageControl] setUserInteractionEnabled:NO];
    [self setTutorialScreens:[[NSMutableArray alloc] init]];
    [self setTutorialDataSources:[[NSMutableArray alloc] init]];
    [self addContent];
}

- (void)addContent {
    CGRect contentFrame = CGRectZero;
    contentFrame.origin.x = HEMTutorialContentHorzPadding;
    contentFrame.size.width = CGRectGetWidth([[self contentContainerView] bounds]) - (2*HEMTutorialContentHorzPadding);
    contentFrame.size.height = CGRectGetHeight([[self contentContainerView] bounds]);
    
    NSInteger index = 0;
    for (HEMTutorialContent* content in [self tutorials]) {
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layout setMinimumLineSpacing:0.0f];
        
        UICollectionView* screen = [[UICollectionView alloc] initWithFrame:contentFrame collectionViewLayout:layout];
        [screen setBackgroundColor:[UIColor whiteColor]];
        [screen setDelegate:self];
        [screen setTag:index];
        [[screen layer] setCornerRadius:HEMTutorialContentCornerRadius];
        
        if ([[self tutorialScreens] count] > 0) {
            [screen setTransform:CGAffineTransformMakeScale(HEMTutorialContentMinScale, HEMTutorialContentMinScale)];
            [screen setAlpha:HEMTutorialContentNextScreenOpacity];
        }
        
        HEMTutorialDataSource* dataSource = [[HEMTutorialDataSource alloc] initWithContent:content forCollectionView:screen];
        [screen setDataSource:dataSource];
        
        [[self tutorialDataSources] addObject:dataSource];
        [[self tutorialScreens] addObject:screen];
        [[self contentContainerView] insertSubview:screen atIndex:0];
        
        contentFrame.origin.x = CGRectGetMaxX(contentFrame) - HEMTutorialContentHorzPadding;
        index++;
    }
    
    CGSize contentSize = [[self contentContainerView] contentSize];
    contentSize.width = CGRectGetWidth([[self contentContainerView] bounds]) * index;
    [[self contentContainerView] setContentSize:contentSize];
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

- (void)scrollContent {
    UIScrollView* scrollView = [self contentContainerView];
    CGFloat offsetX = [scrollView contentOffset].x;
    if (offsetX < 0) {
        return;
    }

    CGFloat scrollWidth = CGRectGetWidth([scrollView bounds]);
    CGFloat previousAdjustedMaxX = 0.0f;
    CGFloat fullTutorialScreenWidth = scrollWidth - (3 * HEMTutorialContentHorzPadding);
    
    for (UICollectionView* screen in [self tutorialScreens]) {
        CGFloat screenScale = [screen transform].a;
        CGFloat scaledX = floorf(CGRectGetMinX([screen frame]) * screenScale);
        CGFloat diff = scaledX - offsetX;
        
        if (CGRectIntersectsRect([scrollView bounds], [screen frame])) {

            if (diff < fullTutorialScreenWidth && diff > HEMTutorialContentHorzPadding) {
                CGFloat fullnessPercentage = MIN(fabs(1 - ((diff - HEMTutorialContentHorzPadding) / fullTutorialScreenWidth)), 1.0f);
                CGFloat adjustedScale = MIN(HEMTutorialContentMinScale + ((1 - HEMTutorialContentMinScale) * fullnessPercentage), 1.0f);
                CGFloat adjustedAlpha = MIN(HEMTutorialContentNextScreenOpacity + ((1 - HEMTutorialContentNextScreenOpacity) * fullnessPercentage), 1.0f);
                CGFloat adjustedX = 0.0f;
                
                if (scaledX < offsetX + fullTutorialScreenWidth) {
                    CGFloat addlPadding = [screen tag] > 2 ? 1 : 0;
                    adjustedX = ((3+addlPadding) * HEMTutorialContentHorzPadding * fullnessPercentage);
                }

                CGAffineTransform scaleXForm = CGAffineTransformMakeScale(adjustedScale, adjustedScale);
                CGAffineTransform transXForm = CGAffineTransformMakeTranslation(adjustedX, 0.0f);
                CGAffineTransform combinedXForm = CGAffineTransformConcat(scaleXForm, transXForm);
                
                [screen setAlpha:adjustedAlpha];
                [screen setTransform:combinedXForm];
            }
            
        } else if (diff > 0) {
            CGRect notVisibleScreenFrame = [screen frame];
            notVisibleScreenFrame.origin.x = previousAdjustedMaxX - (HEMTutorialContentMinScale * screenScale);
            [screen setFrame:notVisibleScreenFrame];
        }
        
        previousAdjustedMaxX = CGRectGetMaxX([screen frame]);
    }

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
    }
}

@end

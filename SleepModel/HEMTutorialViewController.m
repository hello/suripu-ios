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
@property (strong, nonatomic) NSMutableArray* tutorialDataSources;
@property (assign, nonatomic) CGFloat previousScrollOffsetX;

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
        
        contentFrame.origin.x += (CGRectGetWidth(contentFrame) - HEMTutorialContentHorzPadding);
        index++;
    }
    
    CGSize contentSize = [[self contentContainerView] contentSize];
    contentSize.width = CGRectGetMaxX(contentFrame);
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == [self contentContainerView]) {
        CGFloat contentX = [scrollView contentOffset].x;
        BOOL movingRight = contentX > [self previousScrollOffsetX];
        CGFloat scrollWidth = CGRectGetWidth([scrollView bounds]);
        NSInteger pageNumber = contentX / scrollWidth;
        
        if (movingRight) {
            NSInteger currentPage = [[self pageControl] currentPage];
            NSInteger nextPage = currentPage + 1;
            
            if (nextPage < [[self tutorialScreens] count]) {
                UIView* currentScreen = [self tutorialScreens][currentPage];
                UIView* nextScreen = [self tutorialScreens][nextPage];
                
                CGFloat nextPageOffsetX = nextPage * scrollWidth;
                CGFloat percentageToNextPage = MIN(contentX / nextPageOffsetX, 1.0f);
                CGFloat fadedAlpha = HEMTutorialContentNextScreenOpacity;
                CGFloat opacity = MIN(fadedAlpha + ((1 - fadedAlpha) * percentageToNextPage), 1.0f);
                CGFloat smallScale = HEMTutorialContentMinScale;
                CGFloat scale = MIN(smallScale + ((1 - smallScale) * percentageToNextPage), 1.0f);
                CGFloat targetNextX =  CGRectGetMaxX([currentScreen frame]) + (HEMTutorialContentHorzPadding * 2);
                CGPoint nextCenter = [nextScreen center];
                DDLogVerbose(@"percentageToNextPage %f, nextX %f", percentageToNextPage, targetNextX);
                
                // TODO: below is wrong
                nextCenter.x = (percentageToNextPage * targetNextX) + (CGRectGetWidth([nextScreen bounds])/2.0f);
                
                [nextScreen setAlpha:opacity];
                [nextScreen setTransform:CGAffineTransformMakeScale(scale, scale)];
                [nextScreen setCenter:nextCenter];
                
            }
        } else {
            
        }
        
        [[self pageControl] setCurrentPage:pageNumber];
        [self setPreviousScrollOffsetX:contentX];
    }
}

@end

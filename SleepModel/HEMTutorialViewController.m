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
@property (assign, nonatomic) NSInteger currentPage;

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
        
        index++;
        contentFrame.origin.x += (CGRectGetWidth(contentFrame) - (HEMTutorialContentHorzPadding));
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

- (void)scrollToTheRightScreens {
    NSInteger currentPage = [self currentPage];
    NSInteger nextPage = currentPage + 1;
    
    DDLogVerbose(@"right: current page %ld", currentPage);
    
    while (nextPage < [[self tutorialScreens] count]) {
        UIView* nextScreen = [self tutorialScreens][nextPage];
        CGFloat contentX = [[self contentContainerView] contentOffset].x;
        CGFloat scrollWidth = CGRectGetWidth([[self contentContainerView] bounds]);
        CGFloat nextPageOffsetX = nextPage * scrollWidth;
        CGFloat percentageToNextPage = MIN(contentX / nextPageOffsetX, 1.0f);
        CGFloat fadedAlpha = HEMTutorialContentNextScreenOpacity;
        CGFloat opacity = MIN(fadedAlpha + ((1 - fadedAlpha) * percentageToNextPage), 1.0f);
        CGFloat smallScale = HEMTutorialContentMinScale;
        CGFloat scale = MIN(smallScale + ((1 - smallScale) * percentageToNextPage), 1.0f);
        
        // calculate how much distance to move from initial offset x of next screen
        // to the nextPageOffsetX minus padding
        CGFloat nextScreenInitialOffsetX = nextPageOffsetX - (2 * HEMTutorialContentHorzPadding * nextPage);
        CGFloat distanceToMove = nextScreenInitialOffsetX - nextPageOffsetX - HEMTutorialContentHorzPadding;
        
        CGPoint nextCenter = [nextScreen center];
        nextCenter.x = nextScreenInitialOffsetX - (percentageToNextPage * distanceToMove) + (CGRectGetWidth([nextScreen bounds])/2);
        
        [nextScreen setAlpha:opacity];
        [nextScreen setTransform:CGAffineTransformMakeScale(scale, scale)];
        [nextScreen setCenter:nextCenter];
        
        nextPage++;
    }
}

- (void)scrollToTheLeftScreens {
    NSInteger currentPage = [[self pageControl] currentPage];
    NSInteger lastPage = [[self tutorialScreens] count] - 1;
    CGFloat scrollWidth = CGRectGetWidth([[self contentContainerView] bounds]);
    CGFloat lastPageX = lastPage * scrollWidth;
    CGFloat contentX = [[self contentContainerView] contentOffset].x;
    
    DDLogVerbose(@"left: current page %ld", currentPage);
    
    if (currentPage > 0 && contentX < lastPageX - HEMTutorialContentHorzPadding) {
        UIView* currentScreen = [self tutorialScreens][currentPage];

        CGFloat page = contentX / scrollWidth;
        CGFloat percentageMoved = 1.0f - (page - floorf(page));
        
        CGFloat scale = 1.0f - ((1.0f - HEMTutorialContentMinScale) * percentageMoved);
        [currentScreen setTransform:CGAffineTransformMakeScale(scale, scale)];
        
        CGFloat alpha = 1.0f - ((1.0f - HEMTutorialContentNextScreenOpacity) * percentageMoved);
        [currentScreen setAlpha:alpha];
        
        CGFloat halfWidth = CGRectGetWidth([currentScreen bounds]) / 2;
        CGFloat startingX = (currentPage * scrollWidth);
        CGFloat moved = percentageMoved * 2 * HEMTutorialContentHorzPadding;

        CGPoint currentCenter = [currentScreen center];
        currentCenter.x = startingX + halfWidth - moved;
        [currentScreen setCenter:currentCenter];
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
        CGFloat contentX = [scrollView contentOffset].x;
        BOOL movingRight = contentX > [self previousScrollOffsetX];

        if (movingRight) {
            [self scrollToTheRightScreens];
        } else {
            [self scrollToTheLeftScreens];
        }
        
        [self updatePageControl];
        [self setPreviousScrollOffsetX:contentX];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == [self contentContainerView]) {
        [self setCurrentPage:[[self pageControl] currentPage]];
    }
}

@end

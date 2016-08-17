//
//  HEMPillIntroViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENServiceDevice.h>

#import "HEMPillSetupViewController.h"
#import "HEMStyle.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMEmbeddedVideoView.h"
#import "HEMVideoCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "NSAttributedString+HEMUtils.h"

typedef NS_ENUM(NSUInteger, HEMPillSetupRow) {
    HEMPillSetupRowTitle = 0,
    HEMPillSetupRowDescription = 1,
    HEMPillSetupRowIllustration = 2,
    HEMPillSetupRows = 3
};

static CGFloat const HEMPillSetupTextHorzPadding = 20.0f;
static CGFloat const HEMPillSetupLayoutMinLineSpacing = 8.0f;

@interface HEMPillSetupViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;

@property (strong, nonatomic) NSAttributedString* attributedTitle;
@property (strong, nonatomic) NSAttributedString* attributedDescription;
@property (weak,   nonatomic) HEMVideoCollectionViewCell* videoCell;
@property (assign, nonatomic) CGFloat titleHeight;
@property (assign, nonatomic) CGFloat descriptionHeight;
@property (assign, nonatomic) CGFloat videoHeight;
@property (assign, nonatomic, getter=isWaitingForLED) BOOL waitingForLED;

@end

@implementation HEMPillSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureButtonContainerShadow];
    [self configureButtons];
    [self trackAnalyticsEvent:HEMAnalyticsEventPillPlacement];
}

- (void)configureButtons {
    [self enableBackButton:NO];
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.pill-setup", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropPillPlacement];
}

- (void)configureButtonContainerShadow {
    NSShadow* shadow = [NSShadow shadowForButtonContainer];
    CALayer* containerLayer = [[self buttonContainer] layer];
    [containerLayer setShadowColor:[[shadow shadowColor] CGColor]];
    [containerLayer setShadowOffset:[shadow shadowOffset]];
    [containerLayer setShadowRadius:[shadow shadowBlurRadius]];
    [containerLayer setShadowOpacity:1.0f];
}

- (void)calculateHeights {
    NSAttributedString* title = [self attributedTitle];
    [self setTitleHeight:[self heightForAttributedText:title]];
    
    NSAttributedString* desc = [self attributedDecription];
    [self setDescriptionHeight:[self heightForAttributedText:desc]];
    
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    CGFloat contentHeight =
        [layout sectionInset].top
        + [self titleHeight]
        + HEMPillSetupLayoutMinLineSpacing
        + [self descriptionHeight]
        + HEMPillSetupLayoutMinLineSpacing;
    
    UIImage* image = [UIImage imageNamed:@"pillSetup"];
    CGFloat imageHeight = CGRectGetHeight([[self collectionView] bounds]) - contentHeight;
    [self setVideoHeight:MAX(image.size.height, imageHeight)];
}

- (CGFloat)heightForAttributedText:(NSAttributedString*)attributedText {
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    CGFloat itemWidth = [layout itemSize].width;
    return [attributedText sizeWithWidth:itemWidth - (HEMPillSetupTextHorzPadding * 2)].height;
}

- (NSAttributedString*)attributedTitle {
    if (_attributedTitle == nil) {
        _attributedTitle =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"onboarding.pill-setup.title", nil)
                                            attributes:@{NSFontAttributeName : [UIFont h5],
                                                         NSForegroundColorAttributeName : [UIColor boldTextColor]}];
    }
    return _attributedTitle;
}

- (NSAttributedString*)attributedDecription {
    if (_attributedDescription == nil) {
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineHeightMultiple:1.1f];
        _attributedDescription =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"onboarding.pill-setup.description", nil)
                                            attributes:@{NSFontAttributeName : [UIFont body],
                                                         NSForegroundColorAttributeName : [UIColor grey5],
                                                         NSParagraphStyleAttributeName : style}];
    }
    return _attributedDescription;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    [layout setMinimumLineSpacing:HEMPillSetupLayoutMinLineSpacing];
    [layout setItemSize:CGSizeMake(CGRectGetWidth([[self collectionView] bounds]), 0.0f)];
    
    CGFloat contentHeight = [[self collectionView] contentSize].height;
    CGFloat viewHeight = CGRectGetHeight([[self collectionView] bounds]);
    BOOL scroll = contentHeight - HEMPillSetupLayoutMinLineSpacing > viewHeight;
    [[self collectionView] setScrollEnabled:scroll];

    [self calculateHeights];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    HEMEmbeddedVideoView* videoView = [[self videoCell] videoView];
    if (![videoView isReady]) {
        [videoView setReady:YES];
    } else {
        [videoView playVideoWhenReady];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[[self videoCell] videoView] pause];
}

#pragma mark - UICollectionViewDataSource / Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return HEMPillSetupRows;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = nil;
    NSInteger row = [indexPath row];
    NSString* reuseId = nil;
    
    switch (row) {
        case HEMPillSetupRowTitle:
        case HEMPillSetupRowDescription: {
            reuseId = [HEMOnboardingStoryboard pillSetupTextCellReuseIdentifier];
            HEMTextCollectionViewCell* textCell =
                [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                          forIndexPath:indexPath];
            NSAttributedString* attributedText = nil;
            
            if (row == HEMPillSetupRowTitle) {
                attributedText = [self attributedTitle];
            } else {
                attributedText = [self attributedDecription];
            }
            
            [[textCell textLabel] setAttributedText:attributedText];
            
            cell = textCell;
            break;
        }
        case HEMPillSetupRowIllustration: {
            reuseId = [HEMOnboardingStoryboard pillSetupVideoCellReuseIdentifier];
            HEMVideoCollectionViewCell* videoCell
                = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                            forIndexPath:indexPath];
            
            UIImage* firstFrame = [UIImage imageNamed:@"pillSetup"];
            NSString* videoPath = NSLocalizedString(@"video.url.onboarding.pill-setup", nil);
            [[videoCell videoView] setFirstFrame:firstFrame videoPath:videoPath];
            
            [self setVideoCell:videoCell];
            cell = videoCell;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = [indexPath row];
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    
    switch (row) {
        case HEMPillSetupRowTitle:
            itemSize.height = [self titleHeight];
            break;
        case HEMPillSetupRowDescription:
            itemSize.height = [self descriptionHeight];
            break;
        case HEMPillSetupRowIllustration:
            itemSize.height = [self videoHeight];
            break;
        default:
            break;
    }
    
    return itemSize;
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    if (![self continueWithFlowBySkipping:NO]) {
        [self performSegueWithIdentifier:[HEMOnboardingStoryboard pillSetupToColorsSegueIdentifier]
                                  sender:self];
    }
}

@end

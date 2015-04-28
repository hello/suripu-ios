//
//  HEMPillIntroViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENServiceDevice.h>

#import "UIFont+HEMStyle.h"

#import "HEMPillSetupViewController.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingUtils.h"
#import "HEMOnboardingCache.h"
#import "HEMOnboardingStoryboard.h"
#import "HelloStyleKit.h"
#import "HEMURLImageView.h"
#import "HEMImageCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"

typedef NS_ENUM(NSUInteger, HEMPillSetupRow) {
    HEMPillSetupRowTitle = 0,
    HEMPillSetupRowDescription = 1,
    HEMPillSetupRowImage = 2,
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
@property (assign, nonatomic) CGFloat titleHeight;
@property (assign, nonatomic) CGFloat descriptionHeight;
@property (assign, nonatomic) CGFloat imageHeight;
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
    NSShadow* shadow = [HelloStyleKit buttonContainerShadow];
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
    
    UIImage* image = [HelloStyleKit pillSetup];
    CGFloat imageHeight = CGRectGetHeight([[self collectionView] bounds]) - contentHeight;
    [self setImageHeight:MAX(image.size.height, imageHeight)];
}

- (CGFloat)heightForAttributedText:(NSAttributedString*)attributedText {
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    CGFloat itemWidth = [layout itemSize].width;
    
    CGSize constraint = CGSizeZero;
    constraint.width = itemWidth - (HEMPillSetupTextHorzPadding*2);
    constraint.height = MAXFLOAT;
    NSStringDrawingOptions options = NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    CGRect textFrame = [attributedText boundingRectWithSize:constraint options:options context:nil];
    return ceilf(CGRectGetHeight(textFrame));
}

- (NSAttributedString*)attributedTitle {
    if (_attributedTitle == nil) {
        _attributedTitle =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"onboarding.pill-setup.title", nil)
                                            attributes:@{NSFontAttributeName : [UIFont onboardingTitleFont],
                                                         NSForegroundColorAttributeName : [HelloStyleKit onboardingTitleColor]}];
    }
    return _attributedTitle;
}

- (NSAttributedString*)attributedDecription {
    if (_attributedDescription == nil) {
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineHeightMultiple:1.1f];
        _attributedDescription =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"onboarding.pill-setup.description", nil)
                                            attributes:@{NSFontAttributeName : [UIFont onboardingDescriptionFont],
                                                         NSForegroundColorAttributeName : [HelloStyleKit onboardingDescriptionColor],
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
        case HEMPillSetupRowImage: {
            reuseId = [HEMOnboardingStoryboard pillSetupImageCellReuseIdentifier];
            HEMImageCollectionViewCell* imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                                                              forIndexPath:indexPath];
            [[imageCell contentView] setBackgroundColor:[UIColor whiteColor]];
            [[imageCell urlImageView] setImage:[HelloStyleKit pillSetup]];
            cell = imageCell;
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
        case HEMPillSetupRowImage:
            itemSize.height = [self imageHeight];
            break;
        default:
            break;
    }
    
    return itemSize;
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    [[self manager] setLED:SENSenseLEDStateOff completion:nil];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard pillSetupToColorsSegueIdentifier]
                              sender:self];
}

@end

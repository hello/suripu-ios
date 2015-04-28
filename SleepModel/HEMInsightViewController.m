//
//  HEMInsightViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <AttributedMarkdown/markdown_peg.h>

#import <SenseKit/SENInsight.h>
#import <SenseKit/SENAPIInsight.h>

#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"

#import "HEMInsightViewController.h"
#import "HEMMarkdown.h"
#import "HEMActivityCoverView.h"
#import "HEMURLImageView.h"
#import "HEMRootViewController.h"
#import "HEMImageCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"

static CGFloat const HEMInsightImageHeight = 186.0f;
static CGFloat const HEMInsightTextHorzPadding = 24.0f;
static CGFloat const HEMInsightTextVertPadding = 20.0f;

@interface HEMInsightViewController() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) SENInsightInfo* info;
@property (strong, nonatomic) NSError* infoError; // info load error
@property (assign, nonatomic) NSInteger imageRow;
@property (assign, nonatomic) NSInteger titleRow;
@property (assign, nonatomic) NSInteger messageRow;
@property (assign, nonatomic) NSInteger numberOfRows;

@property (copy,   nonatomic) NSAttributedString* attributedTitle;
@property (copy,   nonatomic) NSAttributedString* attributedMessage;

@end

@implementation HEMInsightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInfo];
    [SENAnalytics track:kHEMAnalyticsEventInsight];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)[[self contentView] collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    itemSize.width = CGRectGetWidth([[self contentView] bounds]);
    [layout setItemSize:itemSize];
    
    NSShadow* shadow = [HelloStyleKit insightShadow];
    CALayer* layer = [[self buttonContainer] layer];
    [layer setShadowRadius:[shadow shadowBlurRadius]];
    [layer setShadowOffset:[shadow shadowOffset]];
    [layer setShadowColor:[[shadow shadowColor] CGColor]];
    [layer setShadowOpacity:[self shouldShowShadow] ? 1.0f : 0.0f];
}

- (BOOL)shouldShowShadow {
    return [self bottomOfContent] > CGRectGetHeight([[self contentView] bounds]);
}

- (CGFloat)bottomOfContent {
    UICollectionViewFlowLayout* layout
        = (UICollectionViewFlowLayout*)[[self contentView] collectionViewLayout];
    return [[self contentView] contentSize].height
            - (HEMInsightTextVertPadding * 2) // minus adding
            - [layout sectionInset].bottom;
}

- (void)loadInfo {
    if ([[self insight] isGeneric]) {
        [self showContent];
    } else {
        
        __block HEMActivityCoverView* activity = [[HEMActivityCoverView alloc] init];
        [activity showInView:[self view] activity:YES completion:^{
            __weak typeof(self) weakSelf = self;
            [SENAPIInsight getInfoForInsight:[self insight] completion:^(SENInsightInfo* info, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf setInfoError:error];
                [strongSelf setInfo:info];
                [strongSelf showContent];
                // show the content before we remove the activity
                [activity dismissWithResultText:nil showSuccessMark:NO remove:YES completion:nil];
                
            }];
        }];
        
    }
}

- (NSString*)titleToShow {
    NSString* title = nil;
    if ([[self insight] isGeneric]) {
        title = [[self insight] title];
    } else if ([[[self info] title] length] > 0) {
        title = [[self info] title];
    } else if ([self infoError] != nil) {
        title = NSLocalizedString(@"sleep.insight.info.title.no-text", nil);
    }
    return title;
}

- (NSString*)messageToShow {
    NSString* message = nil;
    if ([[self insight] isGeneric]) {
        message = [[self insight] message];
    } else if ([[[self info] info] length] > 0) {
        message = [[self info] info];
    } else if ([self infoError] != nil) {
        message = NSLocalizedString(@"sleep.insight.info.message.no-text", nil);
    }
    return message;
}

- (void)showContent {
    NSInteger row = -1;
    
    [self setImageRow:[[[self info] imageURI] length] > 0 ? ++row : row];
    [self setTitleRow:[[self titleToShow] length] > 0 ? ++row : row];
    [self setMessageRow:[[self messageToShow] length] > 0 ? ++row : row];
    [self setNumberOfRows:row + 1];
    
    [[self contentView] reloadData];
}

- (NSAttributedString*)attributedTitle {
    if (_attributedTitle != nil) return _attributedTitle;
    
    NSString* title = [self titleToShow];
    if (title == nil) return nil;
    
    NSDictionary* attributes = [HEMMarkdown attributesForInsightTitleViewText][@(PARA)];
    _attributedTitle = [[[NSAttributedString alloc] initWithString:title
                                                       attributes:attributes] copy];
    return _attributedTitle;
}

- (NSAttributedString*)attributedMessage {
    if (_attributedMessage != nil) return _attributedMessage;
    
    NSString* message = [self messageToShow];
    if (message == nil) return nil;
    
    NSDictionary* attributes = [HEMMarkdown attributesForInsightViewText];
    _attributedMessage = [markdown_to_attr_string(message, 0, attributes) copy];
    return _attributedMessage;
}

#pragma mark - DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self numberOfRows];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = nil;
    NSInteger row = [indexPath row];
    NSString* reuseId = nil;
    
    if (row == [self imageRow]) {
        reuseId = [HEMMainStoryboard imageReuseIdentifier];
        HEMImageCollectionViewCell* imageCell =
            [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                      forIndexPath:indexPath];
        [[imageCell urlImageView] setImageWithURL:[[self info] imageURI]];
        cell = imageCell;
    } else {
        reuseId = [HEMMainStoryboard textReuseIdentifier];
        HEMTextCollectionViewCell* textCell =
            [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                      forIndexPath:indexPath];
        NSAttributedString* attributedText = nil;
        BOOL showSeparator = NO;
        
        if (row == [self titleRow]) {
            attributedText = [self attributedTitle];
            showSeparator = YES;
        } else { // must be info row
            attributedText = [self attributedMessage];
        }
        
        [[textCell textLabel] setAttributedText:attributedText];
        [[textCell separator] setHidden:!showSeparator];
         
        cell = textCell;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = [indexPath row];
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)[[self contentView] collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    
    if (row == [self imageRow]) {
        itemSize.height = HEMInsightImageHeight;
    } else {
        NSAttributedString* attributedText = nil;
        
        if (row == [self titleRow]) {
            attributedText = [self attributedTitle];
        } else {
            attributedText = [self attributedMessage];
        }
        
        CGSize constraint = CGSizeZero;
        constraint.width = itemSize.width - (HEMInsightTextHorzPadding*2);
        constraint.height = MAXFLOAT;
        NSStringDrawingOptions options = NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
        CGRect textFrame = [attributedText boundingRectWithSize:constraint options:options context:nil];
        itemSize.height = ceilf(CGRectGetHeight(textFrame) + (HEMInsightTextVertPadding*2));
    }
    
    return itemSize;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat yOffset = [scrollView contentOffset].y;
    CGFloat currentBottom = CGRectGetHeight([scrollView bounds])+yOffset;
    CGFloat percentage = MIN(MAX(0.0f, ([self bottomOfContent] - currentBottom)/10.0f), 1.0f);
    [[[self buttonContainer] layer] setShadowOpacity:percentage];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

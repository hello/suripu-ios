//
//  HEMVoiceFeedPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceFeedPresenter.h"
#import "HEMVoiceService.h"
#import "HEMSubNavigationView.h"
#import "HEMVoiceCommandsCell.h"
#import "HEMWelcomeVoiceCell.h"
#import "HEMMainStoryboard.h"
#import "HEMVoiceCommandGroup.h"
#import "HEMVoiceExampleView.h"
#import "HEMStyle.h"

typedef NS_ENUM(NSUInteger, HEMVoiceFeedRowType) {
    HEMVoiceFeedRowTypeWelcome,
    HEMVoiceFeedRowTypeCommands
};

@interface HEMVoiceFeedPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) HEMSubNavigationView* subNavBar;
@property (nonatomic, strong) NSArray<NSNumber*>* rows;

@end

@implementation HEMVoiceFeedPresenter

- (instancetype)initWithVoiceService:(HEMVoiceService*)voiceService {
    if (self = [super init]) {
        _voiceService = voiceService;
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [self setCollectionView:collectionView];
    [self updateUI];
}

- (void)bindWithSubNavigationBar:(HEMSubNavigationView*)subNavBar {
    [self setSubNavBar:subNavBar];
    [super bindWithShadowView:[subNavBar shadowView]];
}

- (void)updateUI {
    NSMutableArray* rows = [NSMutableArray arrayWithCapacity:2];
    if ([[self voiceService] showVoiceIntro]) {
        [rows addObject:@(HEMVoiceFeedRowTypeWelcome)];
    }
    [rows addObject:@(HEMVoiceFeedRowTypeCommands)];
    [self setRows:rows];
    [[self collectionView] reloadData];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self rows] count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* rowValue = [self rows][[indexPath row]];
    HEMVoiceFeedRowType type = [rowValue unsignedIntegerValue];
    
    UICollectionViewFlowLayout* layout = (id) collectionViewLayout;
    NSArray<HEMVoiceCommandGroup*>* commands = [[self voiceService] availableVoiceCommands];
    CGSize itemSize = [layout itemSize];
    
    switch (type) {
        case HEMVoiceFeedRowTypeWelcome: {
            NSString* message = NSLocalizedString(@"voice.welcome.message", nil);
            itemSize.height = [HEMWelcomeVoiceCell heightWithMessage:message
                                                            withFont:[UIFont bodySmall]
                                                           cellWidth:itemSize.width];
            break;
        }
        case HEMVoiceFeedRowTypeCommands:
        default:
            itemSize.height = [HEMVoiceCommandsCell heightWithNumberOfCommands:[commands count]];
            break;
    }

    return itemSize;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    NSNumber* rowValue = [self rows][[indexPath row]];
    HEMVoiceFeedRowType type = [rowValue unsignedIntegerValue];
    switch (type) {
        case HEMVoiceFeedRowTypeWelcome:
            reuseId = [HEMMainStoryboard welcomeReuseIdentifier];
            break;
        default:
            reuseId = [HEMMainStoryboard commandsReuseIdentifier];
            break;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMVoiceCommandsCell class]]) {
        [self configureCommandsCell:(id)cell];
    } else if ([cell isKindOfClass:[HEMWelcomeVoiceCell class]]) {
        [self configureWelcomeCell:(id)cell];
    }
}

- (void)configureCommandsCell:(HEMVoiceCommandsCell*)commandsCell {
    NSArray<HEMVoiceCommandGroup*>* groups = [[self voiceService] availableVoiceCommands];
    [commandsCell setEstimatedNumberOfCommands:[groups count]];
    
    NSUInteger index = 0;
    for (HEMVoiceCommandGroup* group in groups) {
        NSString* exampleWithQuote = [NSString stringWithFormat:@"\"%@\"", [group example]];
        HEMVoiceExampleView* exampleView =
            [commandsCell addCommandWithCategory:[group categoryName]
                                         example:exampleWithQuote
                                            icon:[UIImage imageNamed:[group iconNameSmall]]];
        [exampleView setTag:index++];
        [[exampleView tapGesture] addTarget:self action:@selector(didTapOnCommandGroup:)];
    }
}

- (void)configureWelcomeCell:(HEMWelcomeVoiceCell*)welcomeCell {
    [[welcomeCell titleLabel] setText:[NSLocalizedString(@"voice.welcome.title", nil) uppercaseString]];
    [[welcomeCell titleLabel] setFont:[UIFont h7]];
    [[welcomeCell titleLabel] setTextColor:[UIColor grey6]];
    [[welcomeCell messageLabel] setText:NSLocalizedString(@"voice.welcome.message", nil)];
    [[welcomeCell messageLabel] setFont:[UIFont bodySmall]];
    [[welcomeCell messageLabel] setTextColor:[UIColor grey5]];
    [[welcomeCell closeButton] setTintColor:[UIColor grey4]];
    [[[welcomeCell closeButton] titleLabel] setFont:[UIFont h7Bold]];
    [[welcomeCell closeButton] addTarget:self
                                  action:@selector(dismissWelcome)
                        forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Actions

- (void)didTapOnCommandGroup:(UITapGestureRecognizer*)tap {
    NSArray<HEMVoiceCommandGroup*>* groups = [[self voiceService] availableVoiceCommands];
    UIView* groupView = [tap view];
    switch ([tap state]) {
        case UIGestureRecognizerStateEnded: {
            HEMVoiceCommandGroup* group = groups[[groupView tag]];
            [[self feedDelegate] didTapOnCommandGroup:group fromPresenter:self];
            break;
        }
        default:
            break;
    }
}

- (void)dismissWelcome {
    NSNumber* welcomeType = @(HEMVoiceFeedRowTypeWelcome);
    if ([[self rows] containsObject:welcomeType]) {
        NSInteger indexOfWelcome = [[self rows] indexOfObject:welcomeType];
        NSIndexPath* indexPathOfWelcome = [NSIndexPath indexPathForItem:indexOfWelcome inSection:0];
        
        NSMutableArray* rows = [[self rows] mutableCopy];
        [rows removeObject:welcomeType];
        [self setRows:rows];
        
        [[self collectionView] performBatchUpdates:^{
            [[self collectionView] deleteItemsAtIndexPaths:@[indexPathOfWelcome]];
        } completion:^(BOOL finished) {
            [[self voiceService] hideVoiceIntro];
        }];
    }
}

@end

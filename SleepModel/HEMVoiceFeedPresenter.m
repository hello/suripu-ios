//
//  HEMVoiceFeedPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENVoiceCommandGroup.h>

#import "Sense-Swift.h"
#import "SENRemoteImage+HEMDeviceSpecific.h"

#import "HEMVoiceFeedPresenter.h"
#import "HEMVoiceService.h"
#import "HEMSubNavigationView.h"
#import "HEMVoiceCommandsCell.h"
#import "HEMWelcomeVoiceCell.h"
#import "HEMMainStoryboard.h"
#import "HEMVoiceExampleView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMTextCollectionViewCell.h"

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
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) NSArray<SENVoiceCommandGroup*>* commands;
@property (nonatomic, strong) NSArray<NSString*>* exampleCommands;

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
    [collectionView applyStyle];
    [self setCollectionView:collectionView];
    [self updateUI];
}

- (void)bindWithSubNavigationBar:(HEMSubNavigationView*)subNavBar {
    [self setSubNavBar:subNavBar];
    [super bindWithShadowView:[subNavBar shadowView]];
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator {
    [self setActivityIndicator:activityIndicator];
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

#pragma mark - Presenter events

- (void)didChangeTheme:(Theme *)theme auto:(BOOL)automatically {
    [super didChangeTheme:theme auto:automatically];
    [[self collectionView] applyStyle];
    [[self collectionView] reloadData];
}

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self loadCommands];
}

- (void)didAppear {
    [super didAppear];
    [self loadCommands];
}

- (void)loadCommands {
    [[self activityIndicator] start];
    [[self activityIndicator] setHidden:NO];
    
    __weak typeof(self) weakSelf = self;
    [[self voiceService] availableVoiceCommands:^(NSArray* commandGroups) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSMutableArray* examples = [NSMutableArray arrayWithCapacity:[commandGroups count]];
        for (SENVoiceCommandGroup* group in commandGroups) {
            [examples addObject:[strongSelf exampleFrom:group]];
        }
        [strongSelf setExampleCommands:examples];
        [strongSelf setCommands:commandGroups];
        [[strongSelf activityIndicator] stop];
        [[strongSelf activityIndicator] setHidden:YES];
        [[strongSelf collectionView] reloadData];
    }];
}

- (NSString*)exampleFrom:(SENVoiceCommandGroup*)group {
    NSString* firstCommand = [[[[group groups] firstObject] commands] firstObject];
    return [NSString stringWithFormat:@"\"%@\"", firstCommand];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self commands] count] > 0 ? [[self rows] count] : 1; // at least 1, so we can show error when there are no commands
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewFlowLayout* layout = (id) collectionViewLayout;
    CGSize itemSize = [layout itemSize];
    
    if (![[self activityIndicator] isAnimating] && [[self commands] count] == 0) {
        UIFont* font = [HEMTextCollectionViewCell defaultTextFont];
        NSString *text = NSLocalizedString(@"voice.no-data", nil);
        CGFloat leftMargin = [SenseStyle floatWithGroup:GroupErrors property:ThemePropertyMarginLeft];
        CGFloat rightMargin = [SenseStyle floatWithGroup:GroupErrors property:ThemePropertyMarginRight];
        CGFloat topMargin = [SenseStyle floatWithGroup:GroupErrors property:ThemePropertyMarginTop];
        CGFloat botMargin = [SenseStyle floatWithGroup:GroupErrors property:ThemePropertyMarginBottom];
        CGFloat maxWidth = itemSize.width - leftMargin - rightMargin;
        CGFloat textHeight = [text heightBoundedByWidth:maxWidth usingFont:font];
        CGFloat cardHeight = textHeight + topMargin + botMargin;
        itemSize.height = cardHeight;
        return itemSize;
    }
    
    NSNumber* rowValue = [self rows][[indexPath row]];
    HEMVoiceFeedRowType type = [rowValue unsignedIntegerValue];
    
    switch (type) {
        case HEMVoiceFeedRowTypeWelcome: {
            NSString* message = NSLocalizedString(@"voice.welcome.message", nil);
            itemSize.height = [HEMWelcomeVoiceCell heightWithMessage:message cellWidth:itemSize.width];
            break;
        }
        case HEMVoiceFeedRowTypeCommands:
        default:
            itemSize.height = [HEMVoiceCommandsCell heightWithCommands:[self exampleCommands]
                                                              maxWidth:itemSize.width];
            break;
    }

    return itemSize;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    
    if (![[self activityIndicator] isAnimating] && [[self commands] count] == 0) {
        reuseId = [HEMMainStoryboard errorReuseIdentifier];
    } else {
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
    } else if ([cell isKindOfClass:[HEMTextCollectionViewCell class]]) {
        [self configureErrorCell:(id)cell];
    }
}

- (void)configureErrorCell:(HEMTextCollectionViewCell*)errorCell {
    NSString *text = NSLocalizedString(@"voice.no-data", nil);
    [[errorCell textLabel] setText:text];
}

- (void)configureCommandsCell:(HEMVoiceCommandsCell*)commandsCell {
    [commandsCell setEstimatedNumberOfCommands:[[self commands] count]];
    
    UICollectionViewFlowLayout* layout = (id) [[self collectionView] collectionViewLayout];
    CGSize itemSize = [layout itemSize];

    SENRemoteImage* image = nil;
    NSUInteger index = 0;
    for (SENVoiceCommandGroup* group in [self commands]) {
        image = [group iconImage];
        HEMVoiceExampleView* exampleView =
            [commandsCell addCommandWithCategory:[group localizedTitle]
                                         example:[self exampleFrom:group]
                                            icon:[[group iconImage] uriForCurrentDevice]
                                       cellWidth:itemSize.width];
        [exampleView setTag:index++];
        [[exampleView tapGesture] addTarget:self action:@selector(didTapOnCommandGroup:)];
        [exampleView applyStyle];
    }
    
    [commandsCell applyStyle];
}

- (void)configureWelcomeCell:(HEMWelcomeVoiceCell*)welcomeCell {
    [[welcomeCell titleLabel] setText:[NSLocalizedString(@"voice.welcome.title", nil) uppercaseString]];
    [[welcomeCell messageLabel] setText:NSLocalizedString(@"voice.welcome.message", nil)];
    [[welcomeCell closeButton] addTarget:self
                                  action:@selector(dismissWelcome)
                        forControlEvents:UIControlEventTouchUpInside];
    [welcomeCell applyStyle];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Actions

- (void)didTapOnCommandGroup:(UITapGestureRecognizer*)tap {
    UIView* groupView = [tap view];
    switch ([tap state]) {
        case UIGestureRecognizerStateEnded: {
            SENVoiceCommandGroup* group = [self commands][[groupView tag]];
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

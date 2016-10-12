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
#import "HEMMainStoryboard.h"
#import "HEMVoiceCommand.h"
#import "HEMStyle.h"

@interface HEMVoiceFeedPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) HEMSubNavigationView* subNavBar;

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
}

- (void)bindWithSubNavigationBar:(HEMSubNavigationView*)subNavBar {
    [self setSubNavBar:subNavBar];
    [super bindWithShadowView:[subNavBar shadowView]];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1; // for now, always 1 for the commands list
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout* layout = (id) collectionViewLayout;
    NSArray<HEMVoiceCommand*>* commands = [[self voiceService] availableVoiceCommands];
    CGSize itemSize = [layout itemSize];
    itemSize.height = [HEMVoiceCommandsCell heightWithNumberOfCommands:[commands count]];
    return itemSize;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [HEMMainStoryboard commandsReuseIdentifier];
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    HEMVoiceCommandsCell* commandsCell = (id)cell;
    NSString* voiceTitle = [NSLocalizedString(@"voice.command.list.title", nil) uppercaseString];
    [[commandsCell titleLabel] setFont:[UIFont h7Bold]];
    [[commandsCell titleLabel] setText:voiceTitle];
    [[commandsCell titleLabel] setTextColor:[UIColor grey6]];
    [[commandsCell separatorView] setBackgroundColor:[UIColor separatorColor]];
    
    NSArray<HEMVoiceCommand*>* commands = [[self voiceService] availableVoiceCommands];
    [commandsCell setEstimatedNumberOfCommands:[commands count]];
    
    for (HEMVoiceCommand* command in commands) {
        NSString* exampleWithQuote = [NSString stringWithFormat:@"\"%@\"", [command example]];
        [commandsCell addCommandWithCategory:[command categoryName]
                                     example:exampleWithQuote
                                        icon:[UIImage imageNamed:[command iconNameSmall]]];
    }
    
}

@end

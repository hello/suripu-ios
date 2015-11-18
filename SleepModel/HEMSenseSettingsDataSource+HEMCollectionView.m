//
//  HEMSenseSettingsDataSource+HEMCollectionView.m
//  Sense
//
//  Created by Jimmy Lu on 11/18/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "UIColor+HEMStyle.h"
#import "NSAttributedString+HEMUtils.h"

#import "HEMSenseSettingsDataSource+HEMCollectionView.h"
#import "HEMMainStoryboard.h"
#import "HEMDeviceActionCell.h"
#import "HEMWarningCollectionViewCell.h"
#import "HEMDeviceWarning.h"
#import "HEMActionButton.h"

static NSString* const HEMSenseSettingsHeaderReuseId = @"sectionHeader";

@implementation HEMSenseSettingsDataSource (HEMCollectionView)

- (void)mapWarning:(HEMDeviceWarning*)warning toCell:(HEMWarningCollectionViewCell*)cell {
    [[cell warningMessageLabel] setAttributedText:[warning localizedMessage]];
    [[cell warningSummaryLabel] setText:[warning localizedSummary]];
    [[cell actionButton] setTitle:[NSLocalizedString(@"actions.troubleshoot", nil) uppercaseString]
                                forState:UIControlStateNormal];
    [[cell actionButton] setUserInteractionEnabled:NO]; // let cell be tappable
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger warningCount = [[self deviceWarnings] count];
    return warningCount == 0 ? 2 : warningCount + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSInteger warningCount = [[self deviceWarnings] count];
    // 1 warning per section, if warnings.  If no warnings, show connecting
    // connected cell.  Always show a section for actions
    return section == 0 || section < warningCount ? 1 : 4;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger sec = [indexPath section];
    NSString* reuseId = nil;
    
    if (sec < [[self deviceWarnings] count]) {
        reuseId = [HEMMainStoryboard warningReuseIdentifier];
    } else if (sec == 0) {
        reuseId = [HEMMainStoryboard connectionReuseIdentifier];
    } else {
        reuseId = [HEMMainStoryboard actionReuseIdentifier];
    }
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                                           forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HEMDeviceActionCell class]]) {
        if (sec == 0) {
            [self updateConnectionCell:(id)cell];
        } else {
            [self updateActionCell:(id)cell forRow:[indexPath row]];
        }
    } else if ([cell isKindOfClass:[HEMWarningCollectionViewCell class]]) {
        HEMDeviceWarning* warning = [self deviceWarnings][sec];
        HEMWarningCollectionViewCell* warningCell = (HEMWarningCollectionViewCell*)cell;
        [self mapWarning:warning toCell:warningCell];
    }
    
    return cell;
}

- (void)updateConnectionCell:(HEMDeviceActionCell*)actionCell {
    BOOL connected = [self isConnectedToSense];
    NSString* message = nil;
    if (connected) {
        message = NSLocalizedString(@"settings.sense.connected", nil);
    } else {
        message = NSLocalizedString(@"settings.sense.connecting", nil);
    }
    [actionCell showActivity:!connected withText:message];
    [[actionCell separatorView] setHidden:NO];
    [[actionCell topSeparatorView] setHidden:NO];
    [[actionCell iconView] setImage:[UIImage imageNamed:@"settingsConnectedIcon"]];
}

- (void)updateActionCell:(HEMDeviceActionCell*)actionCell forRow:(NSInteger)row {
    UIImage* icon = nil;
    NSString* actionText = nil;
    BOOL showSeparator = YES;
    BOOL connectedToSense = [self isConnectedToSense];
    BOOL enabled = YES;
    BOOL showTopSeparator = NO;
    
    switch (row) {
        case HEMSenseActionPairingMode:
            icon = [UIImage imageNamed:@"settingsPairingModeIcon"];
            actionText = NSLocalizedString(@"settings.sense.action.pairing-mode", nil);
            enabled = connectedToSense;
            showTopSeparator = YES;
            break;
        case HEMSenseActionEditWiFi:
            icon = [UIImage imageNamed:@"settingsEditWiFiIcon"];
            actionText = NSLocalizedString(@"settings.sense.action.edit-wifi", nil);
            enabled = connectedToSense;
            break;
        case HEMSenseActionChangeTimeZone:
            icon = [UIImage imageNamed:@"settingsTimeZoneIcon"];
            actionText = NSLocalizedString(@"settings.sense.action.change-time-zone", nil);
            break;
        case HEMSenseActionAdvanced:
            icon = [UIImage imageNamed:@"settingsAdvanceIcon"];
            actionText = NSLocalizedString(@"settings.sense.action.advanced", nil);
            showSeparator = NO;
            break;
        default:
            break;
    }
    
    [actionCell setEnabled:enabled];
    [[actionCell textLabel] setText:actionText];
    [[actionCell iconView] setImage:icon];
    [[actionCell separatorView] setHidden:!showSeparator];
    [[actionCell topSeparatorView] setHidden:!showTopSeparator];
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView* view = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:HEMSenseSettingsHeaderReuseId
                                                         forIndexPath:indexPath];
        [view setBackgroundColor:[UIColor backViewBackgroundColor]];
    }
    
    return view;
    
}

- (CGSize)sizeForItemAtPath:(NSIndexPath*)indexPath inCollectionView:(UICollectionView*)collectionView {
    UICollectionViewFlowLayout* layout = (id) [collectionView collectionViewLayout];
    CGSize size = [layout itemSize];
    size.width = CGRectGetWidth([collectionView bounds]);
    
    NSInteger sec = [indexPath section];
    
    if (sec < [[self deviceWarnings] count]) {
        CGFloat widthConstraint = size.width - (2*HEMWarningCellMessageHorzPadding);
        HEMDeviceWarning* warning = [self deviceWarnings][sec];
        NSAttributedString* message = [warning localizedMessage];
        size.height = [message sizeWithWidth:widthConstraint].height + HEMWarningCellBaseHeight;
    } else {
        size.height = HEMDeviceActionCellHeight;
    }
    
    return size;
}

@end

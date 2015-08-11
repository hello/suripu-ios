//
//  HEMTutorialDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 6/9/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTutorialDataSource.h"
#import "HEMTutorialContent.h"
#import "HEMImageCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMURLImageView.h"
#import "UIFont+HEMStyle.h"

static NSString* const HEMTutorialCellReuseIdImage = @"image";
static NSString* const HEMTutorialCellReuseIdTitle = @"title";
static NSString* const HEMTutorialCellReuseIdDesc = @"description";

static CGFloat const HEMTutorialTextVerticalInset = 24.0f;
static CGFloat const HEMTutorialTextSpacing = 16.0f;

typedef NS_ENUM(NSUInteger, HEMTutorialCellSection) {
    HEMTutorialCellSectionImage = 0,
    HEMTutorialCellSectionText = 1,
    HEMTutorialCellSections = 2
};

typedef NS_ENUM(NSUInteger, HEMTutorialCellTextRow) {
    HEMTutorialCellTextRowTitle = 0,
    HEMTutorialCellTextRowDescription = 1,
    HEMTutorialCellTextRows = 2
};

@interface HEMTutorialDataSource()

@property (nonatomic, strong) HEMTutorialContent* content;
@property (nonatomic, weak)   UICollectionView* collectionView;

@end

@implementation HEMTutorialDataSource

- (instancetype)initWithContent:(HEMTutorialContent*)content
              forCollectionView:(UICollectionView*)collectionView {
    self = [super init];
    if (self) {
        _content = content;
        _collectionView = collectionView;
        [self registerCells];
    }
    return self;
}

- (void)registerCells {
    [[self collectionView] registerClass:[HEMImageCollectionViewCell class]
              forCellWithReuseIdentifier:HEMTutorialCellReuseIdImage];
    [[self collectionView] registerClass:[HEMTextCollectionViewCell class]
              forCellWithReuseIdentifier:HEMTutorialCellReuseIdTitle];
    [[self collectionView] registerClass:[HEMTextCollectionViewCell class]
              forCellWithReuseIdentifier:HEMTutorialCellReuseIdDesc];
}

- (CGSize)sizeForContentAtIndexPath:(NSIndexPath*)indexPath {
    UIEdgeInsets insets = [[self collectionView] contentInset];
    CGSize size = [[self collectionView] bounds].size;
    size.width -= (insets.left + insets.right);
    
    if ([indexPath section] == HEMTutorialCellSectionImage) {
        CGFloat imageWidth = [[self content] image].size.width;
        CGFloat scaledFactor = size.width / imageWidth;
        size.height = [[self content] image].size.height * scaledFactor;
    } else if ([indexPath section] == HEMTutorialCellSectionText) {
        if ([indexPath row] == HEMTutorialCellTextRowTitle) {
            size.height = [HEMTextCollectionViewCell heightWithText:[[self content] title]
                                                               font:[UIFont tutorialTitleFont]
                                                          cellWidth:size.width];
        } else if ([indexPath row] == HEMTutorialCellTextRowDescription) {
            size.height = [HEMTextCollectionViewCell heightWithText:[[self content] text]
                                                               font:[UIFont tutorialDescriptionFont]
                                                          cellWidth:size.width];
        }
    }
    
    return size;
}

- (CGFloat)contentSpacingAtSection:(NSInteger)section {
    return section == HEMTutorialCellSectionText ? HEMTutorialTextSpacing : 0.0f;
}

- (UIEdgeInsets)contentInsetAtSection:(NSInteger)section {
    if (section == HEMTutorialCellSectionText) {
        return UIEdgeInsetsMake(HEMTutorialTextVerticalInset, 0.0f, HEMTutorialTextVerticalInset, 0.0f);
    } else {
        return UIEdgeInsetsZero;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return HEMTutorialCellSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == HEMTutorialCellSectionImage) {
        return 1;
    } else if (section == HEMTutorialCellSectionText) {
        return HEMTutorialCellTextRows;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell* cell = nil;
    
    if ([indexPath section] == HEMTutorialCellSectionImage) {
        cell = [self imageCellFor:collectionView atIndexPath:indexPath];
    } else if ([indexPath section] == HEMTutorialCellSectionText) {
        if ([indexPath row] == HEMTutorialCellTextRowTitle) {
            cell = [self titleCellFor:collectionView atIndexPath:indexPath];
        } else if ([indexPath row] == HEMTutorialCellTextRowDescription) {
            cell = [self descriptionCellFor:collectionView atIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (UICollectionViewCell* )imageCellFor:(UICollectionView*)collectionView atIndexPath:(NSIndexPath*)indexPath {
    HEMImageCollectionViewCell* imageCell =
        (id)[collectionView dequeueReusableCellWithReuseIdentifier:HEMTutorialCellReuseIdImage forIndexPath:indexPath];
    [[imageCell urlImageView] setImage:[[self content] image]];
    [[imageCell urlImageView] setContentMode:UIViewContentModeScaleAspectFit];
    return imageCell;
}

- (UICollectionViewCell*)titleCellFor:(UICollectionView*)collectionView atIndexPath:(NSIndexPath*)indexPath {
    HEMTextCollectionViewCell* titleCell =
        (id)[collectionView dequeueReusableCellWithReuseIdentifier:HEMTutorialCellReuseIdTitle forIndexPath:indexPath];
    [[titleCell textLabel] setFont:[UIFont tutorialTitleFont]];
    [[titleCell textLabel] setText:[[self content] title]];
    return titleCell;
}

- (UICollectionViewCell*)descriptionCellFor:(UICollectionView*)collectionView atIndexPath:(NSIndexPath*)indexPath {
    HEMTextCollectionViewCell* descriptionCell =
        (id)[collectionView dequeueReusableCellWithReuseIdentifier:HEMTutorialCellReuseIdDesc forIndexPath:indexPath];
    [[descriptionCell textLabel] setFont:[UIFont tutorialDescriptionFont]];
    [[descriptionCell textLabel] setText:[[self content] text]];
    [[descriptionCell textLabel] setTextColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];
    return descriptionCell;
}

@end

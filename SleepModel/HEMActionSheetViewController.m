//
//  HEMAlertUtils.m
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMActionSheetViewController.h"
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"

static NSString* const HEMActionSheetOptionColor = @"color";
static NSString* const HEMActionSheetOptionDescription = @"description";
static NSString* const HEMActionSheetOptionActionBlock = @"action";

@interface HEMActionSheetViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *shadedOverlayView;
@property (weak, nonatomic) IBOutlet UITableView *optionTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oTVHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oTVBottomConstraint;

@property (strong, nonatomic) NSMutableArray* orderedOptions;
@property (strong, nonatomic) NSMutableDictionary* options;

@end

@implementation HEMActionSheetViewController

static NSString* const HEMAlertControllerButtonTextKey = @"text";
static NSString* const HEMAlertControllerButtonActionKey = @"action";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setOptions:[NSMutableDictionary dictionary]];
    [self setOrderedOptions:[NSMutableArray array]];
}

- (void)addOptionWithTitle:(NSString *)optionTitle
                titleColor:(UIColor *)color
               description:(NSString *)description
                     block:(void (^)(void))block {

    if (!optionTitle) {
        return;
    }
    
    if (![[self options] objectForKey:optionTitle]) {
        [[self orderedOptions] addObject:optionTitle];
    }
    
    void (^actionBlock)(void) = nil;
    if (block) {
        actionBlock = [block copy];
    } else {
        actionBlock = ^{};
    }
    
    [[self options] setValue:@{HEMActionSheetOptionColor : color ?: [HelloStyleKit senseBlueColor],
                               HEMActionSheetOptionDescription : description ?: @"",
                               HEMActionSheetOptionDescription : actionBlock}
                      forKey:optionTitle];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self orderedOptions] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

@end

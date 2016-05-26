//
//  HEMAlertUtils.m
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMActionSheetViewController.h"
#import "HEMStyle.h"
#import "NSString+HEMUtils.h"
#import "HEMActionSheetOptionCell.h"
#import "HEMMainStoryboard.h"
#import "HEMScreenUtils.h"

static NSString* const HEMActionSheetOptionColor = @"color";
static NSString* const HEMActionSheetOptionImage = @"image";
static NSString* const HEMActionSheetOptionDescription = @"description";
static NSString* const HEMActionSheetOptionActionBlock = @"action";
static NSString* const HEMActionSheetOptionConfirmView = @"confirmation";
static NSString* const HEMActionSheetOptionConfirmDisplayInterval = @"confirm_time";

static CGFloat const HEMActionSheetTitleHorzMargin = 24.0f;
static CGFloat const HEMActionSheetTitleTopMargin = 28.0f;
static CGFloat const HEMActionSheetTitleBottomMargin = 4.0f;
static CGFloat const HEMActionSheetOptionAnimDuration = 0.3f;
static CGFloat const HEMActionSheetConfirmAnimDuration = 1.0f;

CGFloat const HEMActionSheetDefaultCellHeight = 72.0f;

@interface HEMActionSheetViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *shadedOverlayView;
@property (weak, nonatomic) IBOutlet UITableView *optionTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oTVHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oTVBottomConstraint;

@property (strong, nonatomic) NSMutableArray* orderedOptions;
@property (strong, nonatomic) NSMutableDictionary* options;
@property (copy,   nonatomic) HEMActionSheetCallback dismissAction;
@property (strong, nonatomic) UIView* customTitleView;

@end

@implementation HEMActionSheetViewController

static NSString* const HEMAlertControllerButtonTextKey = @"text";
static NSString* const HEMAlertControllerButtonActionKey = @"action";

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setDefaults];
    }
    return self;
}

-(void)setDefaults {
    [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self setOptionTextAlignment:NSTextAlignmentLeft];
    [[self optionTableView] setSeparatorColor:[UIColor separatorColor]];
    [[self optionTableView] setTableFooterView:[[UIView alloc] init]];
}

- (NSUInteger)numberOfOptions {
    return [[self orderedOptions] count];
}

- (void)addOptionWithTitle:(NSString*)optionTitle action:(HEMActionSheetCallback)action {
    [self addOptionWithTitle:optionTitle titleColor:nil description:nil imageName:nil action:action];
}

- (void)addOptionWithTitle:(NSString *)optionTitle
                titleColor:(UIColor *)color
               description:(NSString *)description
                 imageName:(NSString *)imageName
                    action:(HEMActionSheetCallback)action {

    if (!optionTitle) {
        return;
    }
    
    if (![self options]) {
        [self setOptions:[NSMutableDictionary dictionary]];
    }
    
    if (![self orderedOptions]) {
        [self setOrderedOptions:[NSMutableArray array]];
    }
    
    if (![[self options] objectForKey:optionTitle]) {
        [[self orderedOptions] addObject:optionTitle];
    }
    
    HEMActionSheetCallback actionBlock = nil;
    if (action) {
        actionBlock = [action copy];
    } else {
        actionBlock = ^{};
    }
    
    [[self options] setValue:@{HEMActionSheetOptionColor : color ?: [UIColor tintColor],
                               HEMActionSheetOptionDescription : description ?: @"",
                               HEMActionSheetOptionActionBlock : actionBlock,
                               HEMActionSheetOptionImage : imageName ?: @"" }
                      forKey:optionTitle];
}

- (void)addDismissAction:(HEMActionSheetCallback)action {
    [self setDismissAction:action];
}

- (void)addConfirmationView:(UIView*)confirmationView
                 displayFor:(CGFloat)displayTime
         forOptionWithTitle:(NSString*)title {
    
    if (!title) {
        return;
    }

    NSDictionary* existingConfig = [self options][title];
    NSMutableDictionary* optionsConfig = [existingConfig mutableCopy];
    
    if (!optionsConfig) {
        optionsConfig = [NSMutableDictionary dictionaryWithCapacity:2];
    }

    [optionsConfig setValue:confirmationView forKey:HEMActionSheetOptionConfirmView];
    [optionsConfig setValue:@(displayTime) forKey:HEMActionSheetOptionConfirmDisplayInterval];
    [[self options] setValue:optionsConfig forKey:title];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableViewHeader];
    [self configureShadedOverlay];
    [[self view] setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self show];
}

- (void)show {
    [[self optionTableView] reloadData];
    CGRect windowBounds = HEMKeyWindowBounds();
    CGFloat screenHeight = CGRectGetHeight(windowBounds);
    CGFloat contentHeight = [[self optionTableView] contentSize].height;
    
    [[self optionTableView] setScrollEnabled:contentHeight > screenHeight];
    
    CGFloat height = MIN(contentHeight, screenHeight);
    BOOL needsUpdateConstraints = self.oTVBottomConstraint.constant != height
        || self.oTVHeightConstraint.constant != height;
    BOOL needsUpdateAlpha = self.shadedOverlayView.alpha != 1.f;
    self.shadedOverlayView.accessibilityFrame = CGRectMake(0, 0, CGRectGetWidth(windowBounds), screenHeight - height);
    if (needsUpdateConstraints) {
        [[self oTVHeightConstraint] setConstant:height];
        [[self oTVBottomConstraint] setConstant:height];
    }
    [UIView animateWithDuration:HEMActionSheetOptionAnimDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         if (needsUpdateAlpha)
                             [[self shadedOverlayView] setAlpha:1.0f];
                         if (needsUpdateConstraints)
                             [[self view] layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.shadedOverlayView);
                     }];
}

- (void)hide:(void(^)(BOOL finished))completion {
    [[self oTVBottomConstraint] setConstant:0];
    [[self view] setNeedsUpdateConstraints];
    [UIView animateWithDuration:HEMActionSheetOptionAnimDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [[self shadedOverlayView] setAlpha:0.0f];
                         [[self view] layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, NSLocalizedString(@"action-sheet.accessibility.did-disappear", nil));
                         if (completion)
                             completion(finished);
                     }];
}

- (void)hide {
    [self hide:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (BOOL)accessibilityPerformEscape {
    [self hide];
    return YES;
}

#pragma mark - Title

- (UIView*)titleViewWithText:(NSString*)text {
    NSString* uppercaseTitle = [text uppercaseString];
    CGFloat boundedWidth = CGRectGetWidth([[self optionTableView] bounds]);
    CGFloat constraint = boundedWidth - (2*HEMActionSheetTitleHorzMargin);
    CGFloat labelHeight = [uppercaseTitle heightBoundedByWidth:constraint
                                                     usingFont:[UIFont actionSheetTitleFont]];

    CGRect labelFrame = CGRectZero;
    labelFrame.size.width = constraint;
    labelFrame.size.height = labelHeight;
    labelFrame.origin.y = HEMActionSheetTitleTopMargin;
    labelFrame.origin.x = HEMActionSheetTitleHorzMargin;
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setFont:[UIFont actionSheetTitleFont]];
    [label setTextColor:[UIColor colorWithWhite:0.0f alpha:0.4f]];
    [label setText:uppercaseTitle];
    [label setNumberOfLines:0];
    
    CGRect frame = CGRectZero;
    frame.size.width = boundedWidth;
    frame.size.height = CGRectGetMaxY(labelFrame) + HEMActionSheetTitleBottomMargin;
    
    UIView* labelContainer = [[UIView alloc] initWithFrame:frame];
    
    [labelContainer addSubview:label];
    
    return labelContainer;
}

- (void)configureShadedOverlay {
    self.shadedOverlayView.isAccessibilityElement = YES;
    self.shadedOverlayView.accessibilityTraits = UIAccessibilityTraitButton;
    self.shadedOverlayView.accessibilityValue = NSLocalizedString(@"actions.cancel", nil);
    self.shadedOverlayView.backgroundColor = [UIColor seeThroughBackgroundColor];
}

- (void)configureTableViewHeader {
    if ([[self title] length] == 0 && ![self customTitleView]) {
        return;
    }
    
    UIView* titleView = [self customTitleView];
    if (!titleView) {
        titleView = [self titleViewWithText:[self title]];
    }
    
    [[self optionTableView] setTableHeaderView:titleView];
}

- (void)setCustomTitleView:(UIView*)view {
    _customTitleView = view;
}

#pragma mark - Confirmation

- (void)fadeOut:(UIView*)outView thenInComes:(UIView*)inView completion:(void(^)(BOOL finished))completion {
    CGFloat halfDuration = HEMActionSheetConfirmAnimDuration / 2;
    [UIView animateWithDuration:halfDuration animations:^{
        [outView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:halfDuration animations:^{
            [inView setAlpha:1.0f];
        } completion:completion];
    }];
}

- (void)showConfirmation:(UIView*)confirmationView
             forDuration:(CGFloat)duration
              withAction:(HEMActionSheetCallback)action {
    
    [confirmationView setAlpha:0.0f];
    
    UIView* bgView = [[UIView alloc] initWithFrame:[[self optionTableView] frame]];
    
    [confirmationView setFrame:[bgView bounds]];
    
    [bgView setBackgroundColor:[UIColor whiteColor]];
    [bgView addSubview:confirmationView];
    
    [[self view] insertSubview:bgView belowSubview:[self optionTableView]];
    
    if (action) {
        action();
    }
    
    [self fadeOut:[self optionTableView] thenInComes:confirmationView completion:^(BOOL finished) {
        [UIView animateWithDuration:HEMActionSheetOptionAnimDuration
                              delay:duration
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = [bgView frame];
                             frame.origin.y += CGRectGetHeight(frame);
                             [bgView setFrame:frame];
                             [[self shadedOverlayView] setAlpha:0.0f];
                         }
                         completion:^(BOOL finished) {
                             [self dismissViewControllerAnimated:NO completion:nil];
                         }];
    }];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self orderedOptions] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* optionTitle = [self orderedOptions][[indexPath row]];
    NSDictionary* optionAttributes = [[self options] objectForKey:optionTitle];
    NSString* description = [optionAttributes objectForKey:HEMActionSheetOptionDescription];
    return [HEMActionSheetOptionCell heightWithTitle:optionTitle
                                         description:description
                                            maxWidth:CGRectGetWidth([tableView bounds])];
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard optionReuseIdentifier]];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(HEMActionSheetOptionCell *)optionCell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* optionTitle = [self orderedOptions][[indexPath row]];
    NSDictionary* optionAttributes = [[self options] objectForKey:optionTitle];
    NSString* desc = [optionAttributes objectForKey:HEMActionSheetOptionDescription];
    UIColor* titleColor = [optionAttributes objectForKey:HEMActionSheetOptionColor];
    NSString* imageName = optionAttributes[HEMActionSheetOptionImage];
    UIImage* iconImage = imageName ? [UIImage imageNamed:imageName] : nil;
    
    [optionCell setOptionTitle:optionTitle
                     withColor:titleColor
                          icon:iconImage
                   description:desc
                 textAlignment:[self optionTextAlignment]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* optionTitle = [self orderedOptions][[indexPath row]];
    NSDictionary* optionAttributes = [self options][optionTitle];
    UIView* confirmationView = optionAttributes[HEMActionSheetOptionConfirmView];
    
    __block HEMActionSheetCallback action = [optionAttributes objectForKey:HEMActionSheetOptionActionBlock];
    
    if (confirmationView) {
        NSNumber* displayTime = optionAttributes[HEMActionSheetOptionConfirmDisplayInterval];
        [self showConfirmation:confirmationView forDuration:[displayTime floatValue] withAction:action];
    } else {
        [self hide:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:^{
                if (action) {
                    action();
                }
            }];
        }];
    }

}

#pragma mark - Gestures

- (void)dismiss {
    [self dismiss:nil];
}

- (void)dismiss:(void(^)(void))completion {
    [self hide:^(BOOL finished) {
        __block HEMActionSheetCallback dismissBlock = [self dismissAction];
        [self dismissViewControllerAnimated:NO completion:^{
            if (dismissBlock) {
                dismissBlock();
            }
            if (completion) {
                completion();
            }
        }];
    }];
}

- (IBAction)tapOnOverlay:(UITapGestureRecognizer*)gesture {
    [self dismiss];
}

- (IBAction)panOnOverlay:(UIPanGestureRecognizer*)gesture {
    switch ([gesture state]) {
        case UIGestureRecognizerStateBegan:
            [self dismiss];
            break;
        default:
            break;
    }
}

#pragma mark - Clean up

- (void)dealloc {
    [_optionTableView setDataSource:nil];
    [_optionTableView setDelegate:nil];
}

@end

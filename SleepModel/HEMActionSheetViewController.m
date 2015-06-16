//
//  HEMAlertUtils.m
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMActionSheetViewController.h"
#import "HEMActionSheetOptionCell.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"

static NSString* const HEMActionSheetOptionColor = @"color";
static NSString* const HEMActionSheetOptionImage = @"image";
static NSString* const HEMActionSheetOptionDescription = @"description";
static NSString* const HEMActionSheetOptionActionBlock = @"action";

static CGFloat const HEMActionSheetTitleHorzMargin = 24.0f;
static CGFloat const HEMActionSheetTitleTopMargin = 28.0f;
static CGFloat const HEMActionSheetTitleBottomMargin = 4.0f;
static CGFloat const HEMActionSheetOptionAnimDuration = 0.3f;

@interface HEMActionSheetViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *shadedOverlayView;
@property (weak, nonatomic) IBOutlet UITableView *optionTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oTVHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oTVBottomConstraint;

@property (strong, nonatomic) NSMutableArray* orderedOptions;
@property (strong, nonatomic) NSMutableDictionary* options;
@property (copy,   nonatomic) HEMActionSheetCallback dismissAction;

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
    if ([self respondsToSelector:@selector(presentationController)]) {
        [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
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
    
    [[self options] setValue:@{HEMActionSheetOptionColor : color ?: [HelloStyleKit senseBlueColor],
                               HEMActionSheetOptionDescription : description ?: @"",
                               HEMActionSheetOptionActionBlock : actionBlock,
                               HEMActionSheetOptionImage : imageName ?: @"" }
                      forKey:optionTitle];
}

- (void)addDismissAction:(HEMActionSheetCallback)action {
    [self setDismissAction:action];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableViewHeader];
    [[self view] setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self show];
}

- (void)show {
    CGSize optionsContentSize = [[self optionTableView] contentSize];
    CGFloat height = optionsContentSize.height;
    BOOL needsUpdateConstraints = self.oTVBottomConstraint.constant != height
        || self.oTVHeightConstraint.constant != height;
    BOOL needsUpdateAlpha = self.shadedOverlayView.alpha != 1.f;
    if (needsUpdateConstraints) {
        [[self oTVHeightConstraint] setConstant:height];
        [[self oTVBottomConstraint] setConstant:height];
        [[self view] setNeedsUpdateConstraints];
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
                     completion:nil];
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
                     completion:completion];
}

- (void)configureTableViewHeader {
    if ([[self title] length] == 0) {
        return;
    }
    
    CGFloat boundedWidth = CGRectGetWidth([[self optionTableView] bounds]);
    
    CGSize labelConstraint = CGSizeMake(boundedWidth - (2*HEMActionSheetTitleHorzMargin), MAXFLOAT);
    CGFloat labelHeight = [[self title] boundingRectWithSize:labelConstraint
                                                     options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName : [UIFont actionSheetTitleFont]}
                                                     context:nil].size.height;
    CGRect labelFrame = CGRectZero;
    labelFrame.size.width = labelConstraint.width;
    labelFrame.size.height = labelHeight;
    labelFrame.origin.y = HEMActionSheetTitleTopMargin;
    labelFrame.origin.x = HEMActionSheetTitleHorzMargin;
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setFont:[UIFont actionSheetTitleFont]];
    [label setTextColor:[UIColor colorWithWhite:0.0f alpha:0.4f]];
    [label setText:[[self title] uppercaseString]];
    [label setNumberOfLines:0];
    
    CGRect frame = CGRectZero;
    frame.size.width = boundedWidth;
    frame.size.height = CGRectGetMaxY(labelFrame) + HEMActionSheetTitleBottomMargin;
    
    UIView* labelContainer = [[UIView alloc] initWithFrame:frame];
    
    [labelContainer addSubview:label];
    
    [[self optionTableView] setTableHeaderView:labelContainer];
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
    [[optionCell titleLabel] setText:optionTitle];
    [[optionCell titleLabel] setTextColor:[optionAttributes objectForKey:HEMActionSheetOptionColor]];

    NSString* desc = [optionAttributes objectForKey:HEMActionSheetOptionDescription];
    if (desc) {
        [optionCell setDescription:desc];
        [[optionCell descriptionLabel] setTextColor:[UIColor colorWithWhite:0.0f alpha:0.4f]];
    }
    NSString* imageName = optionAttributes[HEMActionSheetOptionImage];
    optionCell.iconImageView.image = imageName.length > 0 ? [UIImage imageNamed:imageName] : nil;
    optionCell.imageViewWidth.constant = optionCell.iconImageView.image.size.width;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* optionTitle = [self orderedOptions][[indexPath row]];
    NSDictionary* optionAttributes = [[self options] objectForKey:optionTitle];
    __block HEMActionSheetCallback action = [optionAttributes objectForKey:HEMActionSheetOptionActionBlock];
    
    [self hide:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            if (action) {
                action();
            }
        }];
    }];
}

#pragma mark - Gestures

- (void)dismiss {
    [self hide:^(BOOL finished) {
        __block HEMActionSheetCallback dismissBlock = [self dismissAction];
        [self dismissViewControllerAnimated:NO completion:^{
            if (dismissBlock) {
                dismissBlock();
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

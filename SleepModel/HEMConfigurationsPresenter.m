//
//  HEMConfigurationsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENExpansion.h>

#import "HEMConfigurationsPresenter.h"
#import "HEMExpansionService.h"
#import "HEMListItemCell.h"
#import "HEMActivityCoverView.h"
#import "HEMMainStoryboard.h"
#import "HEMActionButton.h"
#import "HEMStyle.h"

static CGFloat const kHEMConfigurationSaveDelay = 1.0f;
static CGFloat const kHEMConfigurationAccessoryMargin = 14.0f;
static CGFloat const kHEMConfigurationNoConfigFooterHeight = 36.0f;
static CGFloat const kHEMConfigurationNoConfigFooterMargin = 24.0f;
static CGFloat const kHEMConfigurationNoConfigSeparatorHeight = 1.0f;

@interface HEMConfigurationsPresenter() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* descriptionLabel;
@property (nonatomic, weak) HEMActionButton* saveButton;
@property (nonatomic, weak) UIButton* skipButton;

@property (nonatomic, weak) HEMExpansionService* service;
@property (nonatomic, weak) SENExpansionConfig* selectedConfig;
@property (nonatomic, weak) NSString* configurationName;
@property (nonatomic, strong) SENExpansion* expansion;
@property (nonatomic, strong) NSArray<SENExpansionConfig*>* configs;
@property (nonatomic, strong) UIView* activityContainerView;

@end

@implementation HEMConfigurationsPresenter

- (instancetype)initWithConfigs:(NSArray<SENExpansionConfig*>*)configs
                   forExpansion:(SENExpansion*)expansion
               expansionService:(HEMExpansionService*)service {
    if (self = [super init]) {
        _service = service;
        _configurationName = [service configurationNameForExpansion:expansion];
        _expansion = expansion;
        _configs = configs;
    }
    return self;
}

- (void)bindWithActivityContainer:(UIView*)activityContainerView {
    [self setActivityContainerView:activityContainerView];
}

- (void)bindWithTableView:(UITableView*)tableView {
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setSeparatorColor:[UIColor separatorColor]];
    [tableView setTableFooterView:[self tableFooter]];
    [self setTableView:tableView];
}

- (UIView*)tableFooter {
    if ([[self configs] count] == 0) {
        CGRect labelFrame = CGRectZero;
        labelFrame.size.height = kHEMConfigurationNoConfigFooterHeight;
        labelFrame.origin.x = kHEMConfigurationNoConfigFooterMargin;
        
        NSString* footerFormat = NSLocalizedString(@"expansion.config.no-config.footer.format", nil);
        NSString* footer = [NSString stringWithFormat:footerFormat,
                            [[self expansion] serviceName],
                            [self configurationName]];
        
        UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [label setTextColor:[UIColor grey5]];
        [label setFont:[UIFont h7]];
        [label setText:footer];
        
        CGRect containerFrame = CGRectZero;
        containerFrame.size.height = kHEMConfigurationNoConfigFooterHeight;
        
        UIView* container = [[UIView alloc] initWithFrame:containerFrame];
        [container addSubview:label];
        return container;
    } else {
        return [UIView new];
    }
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel {
    NSString* titleFormat = NSLocalizedString(@"expansion.config.title.format", nil);
    NSString* descriptionFormat = NSLocalizedString(@"expansion.config.description.format", nil);
    NSString* title = [NSString stringWithFormat:titleFormat, [[self expansion] serviceName]];
    NSString* description = [NSString stringWithFormat:descriptionFormat, [self configurationName]];

    [titleLabel setText:title];
    [titleLabel setTextColor:[UIColor grey6]];
    [titleLabel setFont:[UIFont h5]];
    
    [descriptionLabel setText:description];
    [descriptionLabel setTextColor:[UIColor grey5]];
    [descriptionLabel setFont:[UIFont body]];
    
    [self setTitleLabel:titleLabel];
    [self setDescriptionLabel:descriptionLabel];
}

- (void)bindWithSkipButton:(UIButton*)skipButton {
    [skipButton setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [[skipButton titleLabel] setFont:[UIFont button]];
    [skipButton addTarget:self
                   action:@selector(skip)
         forControlEvents:UIControlEventTouchUpInside];
    [self setSkipButton:skipButton];
}

- (void)bindWithDoneButton:(HEMActionButton*)doneButton {
    [doneButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [[doneButton titleLabel] setFont:[UIFont button]];
    [self setSaveButton:doneButton];
}

- (UIImageView*)accessoryViewWithImage:(UIImage*)image withHeight:(CGFloat)height {
    CGRect imageFrame = CGRectZero;
    imageFrame.size.width = image.size.width + kHEMConfigurationAccessoryMargin;
    imageFrame.size.height = height;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:imageFrame];
    [imageView setContentMode:UIViewContentModeCenter];
    return imageView;
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self configs] count] > 0 ? [[self configs] count] : 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard configReuseIdentifier]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = CGRectGetHeight([cell bounds]);
    
    [[cell textLabel] setFont:[UIFont body]];
    
    if ([indexPath row] < [[self configs] count]) {
        SENExpansionConfig* config = [self configs][[indexPath row]];
        [[cell textLabel] setTextColor:[UIColor grey6]];
        [[cell textLabel] setText:[config localizedName]];
        
        if (![cell accessoryView]) {
            UIImage* checkImage = [UIImage imageNamed:@"checkBlue"];
            [cell setAccessoryView:[self accessoryViewWithImage:checkImage withHeight:cellHeight]];
        }
        
        [[cell accessoryView] setHidden:![config isEqual:[self selectedConfig]]];
    } else {
        UIImage* warningImage = [UIImage imageNamed:@"noConfigIcon"];
        NSString* textFormat = NSLocalizedString(@"expansion.config.no-cnfig.format", nil);
        NSString* text = [NSString stringWithFormat:textFormat, [[self configurationName] lowercaseString]];
        
        CGRect separatorFrame = CGRectZero;
        separatorFrame.size.height = kHEMConfigurationNoConfigSeparatorHeight;
        separatorFrame.origin.x = kHEMConfigurationNoConfigFooterMargin;
        separatorFrame.size.width = CGRectGetWidth([cell bounds]);
        separatorFrame.origin.y = cellHeight - kHEMConfigurationNoConfigSeparatorHeight;
        
        UIView* separator = [[UIView alloc] initWithFrame:separatorFrame];
        [separator setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [separator setBackgroundColor:[UIColor separatorColor]];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[cell textLabel] setTextColor:[UIColor grey3]];
        [[cell textLabel] setText:text];
        [cell setAccessoryView:[self accessoryViewWithImage:warningImage withHeight:cellHeight]];
        [[cell contentView] addSubview:separator];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SENExpansionConfig* config = nil;
    if ([indexPath row] < [[self configs] count]) {
        config = [self configs][[indexPath row]];
        [self setSelectedConfig:config];
        [tableView reloadData];
    }
}

#pragma mark - Actions

- (void)skip {
    [[self connectDelegate] didConnect:YES withExpansion:[self expansion]];
    [[self configDelegate] dismissConfigurationFrom:self];
}

- (void)save {
    if ([self selectedConfig]) {
        DDLogVerbose(@"saving configuration");
        
        NSString* textFormat = NSLocalizedString(@"expansion.configuration.activity.updating-config.format", nil);
        NSString* message = [NSString stringWithFormat:textFormat, [self configurationName]];
        HEMActivityCoverView* activityView = [HEMActivityCoverView new];
        
        __weak typeof(self) weakSelf = self;
        void(^finish)(SENExpansion* expansion, NSError* error) = ^(SENExpansion* expansion, NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    // show error
                    NSString* title = NSLocalizedString(@"expansion.error.setup.configuration-not-saved.title", nil);
                    NSString* message = NSLocalizedString(@"expansion.error.setup.configuration-not-saved.message", nil);
                    [[strongSelf errorDelegate] showErrorWithTitle:title andMessage:message withHelpPage:nil fromPresenter:strongSelf];
                }];
            } else {
                [[strongSelf expansion] setState:SENExpansionStateConnectedOn];
                [[strongSelf connectDelegate] didConnect:YES withExpansion:[strongSelf expansion]];
                
                NSString* successText = NSLocalizedString(@"status.success", nil);
                UIImage* successIcon = [UIImage imageNamed:@"check"];
                [activityView updateText:successText successIcon:successIcon hideActivity:YES completion:^(BOOL finished) {
                    [activityView showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                        int64_t delayInSecs =  (int64_t)(kHEMConfigurationSaveDelay * NSEC_PER_SEC);
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInSecs), dispatch_get_main_queue(), ^{
                            [[strongSelf configDelegate] dismissConfigurationFrom:strongSelf];
                        });
                    }];
                }];
            }
        };
        
        [activityView showInView:[self activityContainerView] withText:message activity:YES completion:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[strongSelf service] setConfiguration:[strongSelf selectedConfig]
                                      forExpansion:[strongSelf expansion]
                                        completion:finish];
        }];

    }
}

@end

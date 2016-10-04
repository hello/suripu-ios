//
//  HEMConfigurationsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENExpansion.h>

#import "UIBarButtonItem+HEMNav.h"

#import "HEMConfigurationsPresenter.h"
#import "HEMExpansionService.h"
#import "HEMListItemCell.h"
#import "HEMActivityCoverView.h"

static CGFloat const kHEMConfigurationSaveDelay = 1.0f;

@interface HEMConfigurationsPresenter()

@property (nonatomic, weak) HEMExpansionService* service;
@property (nonatomic, weak) SENExpansionConfig* selectedConfig;
@property (nonatomic, weak) NSString* configurationName;
@property (nonatomic, weak) UIBarButtonItem* saveItem;
@property (nonatomic, strong) SENExpansion* expansion;

@end

@implementation HEMConfigurationsPresenter

- (instancetype)initWithConfigs:(NSArray<SENExpansionConfig*>*)configs
                   forExpansion:(SENExpansion*)expansion
               expansionService:(HEMExpansionService*)service {
    NSString* configurationName = [service configurationNameForExpansion:expansion];
    NSString* titleFormat = NSLocalizedString(@"expansion.configuration.options.title.format", nil);
    NSString* title = [[NSString stringWithFormat:titleFormat, configurationName] uppercaseString];
    self = [super initWithTitle:title items:configs selectedItemNames:nil];
    if (self) {
        _service = service;
        _configurationName = configurationName;
        _expansion = expansion;
    }
    return self;
}

- (void)bindWithNavigationItem:(UINavigationItem *)navItem {
    [super bindWithNavigationItem:navItem];
    
    NSString* title = NSLocalizedString(@"actions.cancel", nil);
    UIBarButtonItem* cancelButton = [UIBarButtonItem cancelItemWithTitle:title
                                                                   image:nil
                                                                  target:self
                                                                  action:@selector(cancel)];
    
    UIBarButtonItem* saveButton = [UIBarButtonItem saveButtonWithTarget:self action:@selector(save)];
    
    [navItem setRightBarButtonItem:saveButton];
    [navItem setTitle:[self configurationName]];
    [navItem setLeftBarButtonItem:cancelButton];
    
    [self setSaveItem:saveButton];
}

#pragma mark - Overrides

- (NSInteger)indexOfItemWithName:(NSString*)name {
    NSInteger index = 0;
    for (SENExpansionConfig* config in [self items]) {
        if ([[config localizedName] isEqualToString:name]) {
            break;
        }
        index++;
    }
    return index;
}

- (void)updateCell:(UITableViewCell *)cell withItem:(id)item selected:(BOOL)selected {
    [super updateCell:cell withItem:item selected:selected];
    if (selected) {
        [[self saveItem] setEnabled:YES];
        [self setSelectedConfig:item];
    }
}

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    SENExpansionConfig* config = item;
    [[cell itemLabel] setText:[config localizedName]];
    [cell setSelected:[config isEqual:[self selectedConfig]]];
}

#pragma mark - Actions

- (void)cancel {
    if ([[self delegate] respondsToSelector:@selector(dismissControllerFromPresenter:)]) {
        [[self delegate] dismissControllerFromPresenter:self];
    }
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
                    [[strongSelf presenterDelegate] presentErrorWithTitle:title message:message from:strongSelf];
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
                            if ([[strongSelf delegate] respondsToSelector:@selector(dismissControllerFromPresenter:)]) {
                                [[strongSelf delegate] dismissControllerFromPresenter:strongSelf];
                            }
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

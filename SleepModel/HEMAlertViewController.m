//
//  HEMAlertViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <AttributedMarkdown/markdown_peg.h>
#import "UIView+HEMSnapshot.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"
#import "HEMRootViewController.h"
#import "HEMAlertViewController.h"
#import "HEMAlertView.h"
#import "HEMSupportUtil.h"
#import "HEMAnimationUtils.h"
#import "HEMMarkdown.h"

@interface HEMAlertViewController()

@property (nonatomic, strong) HEMAlertView* dialogView;
@property (nonatomic, weak)   UIViewController* myPresentingController;
@end

@implementation HEMAlertViewController

+ (void)showInfoDialogWithTitle:(NSString *)title
                        message:(NSString *)message
                     controller:(UIViewController *)controller {
    UIView* view = [HEMRootViewController rootViewControllerForKeyWindow].view;
    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [dialogVC addButtonWithTitle:[NSLocalizedString(@"actions.ok", nil) uppercaseString]
                           style:HEMAlertViewButtonStyleRoundRect
                          action:nil];
    dialogVC.viewToShowThrough = view;
    [dialogVC showFrom:controller];
}

- (instancetype)initBooleanDialogWithTitle:(NSString *)title
                                   message:(NSString *)message
                             defaultsToYes:(BOOL)defaultsToYes
                                    action:(void (^)())action {
    if (self = [super init]) {
        self.title = title;
        _type = HEMAlertViewTypeBoolean;
        _attributedMessage = [[self class] attributedMessageText:message];
        [self addButtonWithTitle:[NSLocalizedString(@"actions.yes", nil) uppercaseString]
                           style:defaultsToYes ? HEMAlertViewButtonStyleBlueBoldText : HEMAlertViewButtonStyleGrayText
                          action:action];
        [self addButtonWithTitle:[NSLocalizedString(@"actions.no", nil) uppercaseString]
                           style:defaultsToYes ? HEMAlertViewButtonStyleGrayText : HEMAlertViewButtonStyleBlueBoldText
                          action:nil];
    }
    return self;
}

+ (NSAttributedString *)attributedMessageText:(NSString *)text {
    NSDictionary *attributes = [HEMMarkdown attributesForAlertMessageText][@(PARA)];
    NSAttributedString* attributedMessage = nil;
    if (text.length > 0)
        attributedMessage = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return attributedMessage;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
    if (self = [super init]) {
        self.title = title;
        _attributedMessage = [HEMAlertViewController attributedMessageText:message];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundView];
}

- (void)addBackgroundView {
    if ([self viewToShowThrough] != nil) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        imageView.translatesAutoresizingMaskIntoConstraints = YES;
        imageView.image = [[self viewToShowThrough] snapshotWithTint:[UIColor alertBackgroundColor]];
        [[self view] insertSubview:imageView atIndex:0];
    } else {
        [[self view] setBackgroundColor:[UIColor alertBackgroundColor]];
    }
}

- (HEMAlertView *)dialogView {
    if (!_dialogView) {
        _dialogView = [[HEMAlertView alloc] initWithImage:self.dialogImage
                                                    title:self.title
                                                     type:self.type
                                        attributedMessage:self.attributedMessage];
    }
    return _dialogView;
}

- (void)addButtonWithTitle:(NSString*)title style:(HEMAlertViewButtonStyle)style action:(HEMDialogActionBlock)block {
    __weak typeof(self) weakSelf = self;
    [[self dialogView] addActionButtonWithTitle:title style:style action:^{
        [weakSelf dismissViewControllerAnimated:YES completion:block];
    }];
}

- (void)onLinkTapOf:(NSString*)url takeAction:(HEMDialogLinkActionBlock)action {
    __weak typeof(self) weakSelf = self;
    [[self dialogView] onLink:url tap:^(NSURL* linkURL) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (action) {
                action(linkURL);
            }
        }];
    }];
}

- (void)showFrom:(UIViewController*)controller {
    self.dialogView.center = self.view.center;
    [self setMyPresentingController:controller];
    [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [controller presentViewController:self animated:YES completion:^{
        [[self dialogView] setTransform:CGAffineTransformMakeScale(0.1f, 0.1f)];
        [[self view] addSubview:[self dialogView]];
        [HEMAnimationUtils grow:[self dialogView] completion:nil];
    }];
}

@end

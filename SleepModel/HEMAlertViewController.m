//
//  HEMAlertViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIView+HEMSnapshot.h"
#import "HEMRootViewController.h"
#import "HEMAlertViewController.h"
#import "HEMAlertView.h"
#import "HEMSupportUtil.h"
#import "HEMAnimationUtils.h"

@interface HEMAlertViewController()

@property (nonatomic, strong) HEMAlertView* dialogView;

@end

@implementation HEMAlertViewController

+ (void)showInfoDialogWithTitle:(NSString *)title
                        message:(NSString *)message
                     controller:(UIViewController *)controller {
    UIView* view = [HEMRootViewController rootViewControllerForKeyWindow].view;
    HEMAlertViewController* dialogVC = [HEMAlertViewController new];
    dialogVC.title = title;
    dialogVC.message = message;
    dialogVC.defaultButtonTitle = NSLocalizedString(@"actions.ok", nil);
    dialogVC.viewToShowThrough = view;
    [dialogVC showFrom:controller onDefaultActionSelected:^{
        [dialogVC dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackgroundView];
}

- (void)addBackgroundView {
    if ([self viewToShowThrough] != nil) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:YES];
        
        UIColor* tint = [UIColor colorWithWhite:0.95f alpha:0.8f];
        UIImage* bgImage = [[self viewToShowThrough] blurredSnapshotWithTint:tint];
        [imageView setImage:bgImage];
        
        [[self view] insertSubview:imageView atIndex:0];
    } else {
        [[self view] setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)updateDialogPosition {
    CGRect dialogFrame = [[self dialogView] frame];
    dialogFrame.origin.x = (CGRectGetWidth([[self view] bounds])-CGRectGetWidth(dialogFrame))/2;
    dialogFrame.origin.y = (CGRectGetHeight([[self view] bounds])-CGRectGetHeight(dialogFrame))/2;
    [[self dialogView] setFrame:dialogFrame];
}

- (void)setupDialogView {
    [self setDialogView:[[HEMAlertView alloc] initWithImage:[self dialogImage]
                                                      title:[self title]
                                                    message:[self message]]];
    
    if ([[self defaultButtonTitle] length] > 0) {
        [[[self dialogView] okButton] setTitle:[self defaultButtonTitle] forState:UIControlStateNormal];
    }
    
    if ([[self helpPage] length] > 0) {
        __weak typeof(self) weakSelf = self;
        [self addAction:NSLocalizedString(@"dialog.help.title", nil)
                primary:NO
            actionBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [HEMSupportUtil openHelpToPage:[strongSelf helpPage] fromController:strongSelf];
            }];
    }
    
    [self updateDialogPosition];
}

- (void)addAction:(NSString*)title primary:(BOOL)primary actionBlock:(HEMDialogActionBlock)block {
    if ([self dialogView] == nil) {
        [self setupDialogView];
    }
    [[self dialogView] addActionButtonWithTitle:title primary:primary action:block];
    [self updateDialogPosition];
}

- (void)showFrom:(UIViewController*)controller onDefaultActionSelected:(HEMDialogActionBlock)doneBlock {
    if ([self dialogView] == nil) {
        [self setupDialogView];
    }
    
    [[self dialogView] onDone:doneBlock];
    
    [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [controller presentViewController:self animated:YES completion:^{
        [[self dialogView] setTransform:CGAffineTransformMakeScale(0.1f, 0.1f)];
        [[self view] addSubview:[self dialogView]];
        [HEMAnimationUtils grow:[self dialogView] completion:nil];
    }];
}

- (void)show:(HEMDialogActionBlock)doneBlock {
    if ([self dialogView] == nil) {
        [self setupDialogView];
    }
    
    [[self dialogView] onDone:doneBlock];
    
    [[self dialogView] setTransform:CGAffineTransformMakeScale(0.1f, 0.1f)];
    [[self view] addSubview:[self dialogView]];
    [HEMAnimationUtils grow:[self dialogView] completion:nil];
}

@end

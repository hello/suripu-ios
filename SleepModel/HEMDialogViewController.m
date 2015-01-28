//
//  HEMDialogViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIView+HEMSnapshot.h"

#import "HEMDialogViewController.h"
#import "HEMDialogView.h"
#import "HEMSupportUtil.h"
#import "HEMAnimationUtils.h"

@interface HEMDialogViewController()

@property (nonatomic, strong) HEMDialogView* dialogView;

@end

@implementation HEMDialogViewController

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
    [self setDialogView:[[HEMDialogView alloc] initWithImage:[self dialogImage]
                                                       title:[self title]
                                                     message:[self message]]];
    
    if ([[self okButtonTitle] length] > 0) {
        [[[self dialogView] okButton] setTitle:[self okButtonTitle] forState:UIControlStateNormal];
    }
    
    if ([self showHelp]) {
        __weak typeof(self) weakSelf = self;
        [self addAction:NSLocalizedString(@"dialog.help.title", nil)
                primary:NO
            actionBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    [HEMSupportUtil openHelpFrom:strongSelf];
                }
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

- (void)showFrom:(UIViewController*)controller onDone:(HEMDialogActionBlock)doneBlock {
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

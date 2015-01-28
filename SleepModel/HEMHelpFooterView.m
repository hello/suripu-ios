//
//  HEMHelpFooterView.m
//  Sense
//
//  Created by Jimmy Lu on 1/22/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import "UIFont+HEMStyle.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "HelloStyleKit.h"
#import "HEMHelpFooterView.h"
#import "HEMSupportUtil.h"

static CGFloat const HEMHelpFooterMargin = 20.0f;
static CGFloat const HEMHelpLineHeightMultiple = 1.2f;

@interface HEMHelpFooterView()<UITextViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) UIViewController* controller;

@end

@implementation HEMHelpFooterView

- (instancetype)initWithWidth:(CGFloat)width
      andContainingController:(UIViewController*)controller {
    
    self = [super init];
    if (self) {
        _controller = controller;
        [self setupWithWidth:width];
    }
    return self;
}

- (void)setupWithWidth:(CGFloat)width {
    CGRect textFrame = {
        HEMHelpFooterMargin,
        0.0f,
        width-(HEMHelpFooterMargin*2),
        0.0f
    };
    CGSize constraint = textFrame.size;
    constraint.height = MAXFLOAT;
    
    UITextView* textView = [[UITextView alloc] init];
    [textView setAttributedText:[self attributedHelpText]];
    [textView setEditable:NO];
    [textView setDelegate:self];
    [textView setScrollEnabled:NO];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setDataDetectorTypes:UIDataDetectorTypeLink|UIDataDetectorTypeAddress];
    [textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    CGSize textSize = [textView sizeThatFits:constraint];
    textFrame.size.height = textSize.height + ([[UIFont settingsHelpFont] lineHeight] * HEMHelpLineHeightMultiple);
    [textView setFrame:textFrame];
    
    CGRect frame = CGRectZero;
    frame.size.width = width;
    frame.size.height = CGRectGetHeight(textFrame) + HEMHelpFooterMargin;
    
    [self setFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    [self addSubview:textView];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

- (NSAttributedString*)attributedHelpText {
    NSString* helpFormat = NSLocalizedString(@"settings.help.format", nil);
    NSArray* args = @[[self supportLink],[self helpEmail]];
    UIColor* color = [HelloStyleKit backViewTextColor];
    UIFont* font = [UIFont settingsHelpFont];
    
    NSMutableAttributedString* attrHelp
        = [[NSMutableAttributedString alloc] initWithFormat:helpFormat
                                                       args:args
                                                  baseColor:color
                                                   baseFont:font];
    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paraStyle setAlignment:NSTextAlignmentCenter];
    [paraStyle setLineHeightMultiple:HEMHelpLineHeightMultiple];
    [attrHelp addAttribute:NSParagraphStyleAttributeName
                     value:paraStyle
                     range:NSMakeRange(0, [attrHelp length])];
    
    return attrHelp;
}

- (NSAttributedString*)supportLink {
    NSString* hyperLinkText = NSLocalizedString(@"settings.help.support", nil);
    NSString* url = NSLocalizedString(@"help.url.support", nil);
    NSMutableAttributedString* link = [[NSMutableAttributedString alloc] initWithString:hyperLinkText];
    [link addAttributes:@{NSLinkAttributeName : url,
                          NSFontAttributeName : [UIFont settingsHelpFont],
                          NSForegroundColorAttributeName : [HelloStyleKit senseBlueColor]}
                  range:NSMakeRange(0, [hyperLinkText length])];
    return link;
}

- (NSAttributedString*)helpEmail {
    NSString* text = NSLocalizedString(@"help.email.address", nil);
    NSMutableAttributedString* helpEmail = [[NSMutableAttributedString alloc] initWithString:text];
    [helpEmail addAttributes:@{NSFontAttributeName : [UIFont settingsHelpFont],
                               NSForegroundColorAttributeName : [HelloStyleKit senseBlueColor]}
                       range:NSMakeRange(0, [text length])];
    return helpEmail;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([self controller] == nil) return YES; // let default behavior handle it
    
    NSString* lowerScheme = [URL scheme];
    if ([lowerScheme hasPrefix:@"mailto"]) {
        [HEMSupportUtil sendEmailTo:[URL resourceSpecifier]
                        withSubject:NSLocalizedString(@"help.email.subject", nil)
                               from:[self controller]
                       mailDelegate:self];
        [SENAnalytics track:kHEMAnalyticsEventEmailSupport];
    } else if ([lowerScheme hasPrefix:@"http"]){
        [HEMSupportUtil openURL:[URL absoluteString] from:[self controller]];
        [SENAnalytics track:kHEMAnalyticsEventHelp];
    }
    return NO;
}

#pragma mark - Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [[self controller] dismissViewControllerAnimated:YES completion:NULL];
}

@end

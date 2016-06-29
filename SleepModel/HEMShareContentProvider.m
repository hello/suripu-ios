//
//  HEMShareContentProvider.m
//  Sense
//
//  Created by Jimmy Lu on 6/21/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMShareContentProvider.h"
#import "NSMutableAttributedString+HEMFormat.h"

static NSString* const HEMShareContentTextFormatKey = @"share.text.format.";
static NSString* const HEMShareContentSubjectKey = @"share.email.subject.";

@interface HEMShareContentProvider()

@property (nonatomic, strong) id itemToShare;
@property (nonatomic, copy) NSString* type;

@end

@implementation HEMShareContentProvider

- (instancetype)initWithItemToShare:(id)itemToShare forType:(NSString*)type {
    self = [super init];
    if (self) {
        _itemToShare = itemToShare;
        _type = [type copy];
    }
    return self;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return [self itemToShare];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([[self itemToShare] isKindOfClass:[NSString class]] && [self type]) {
        NSString* key = [HEMShareContentTextFormatKey stringByAppendingString:[self type]];
        NSString* textFormat = NSLocalizedString(key, nil);
        if (![textFormat isEqualToString:key]) {
            NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:[self itemToShare]];
            NSMutableAttributedString* shareText =
                [[NSMutableAttributedString alloc] initWithFormat:textFormat args:@[attributedString]];
            return [shareText string];
        }
    }
    return [self itemToShare];
}

- (NSString*)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    NSString* key = [HEMShareContentSubjectKey stringByAppendingString:[self type]];
    NSString* text = NSLocalizedString(key, nil);
    return [text isEqualToString:key] ? nil : text;
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController
      thumbnailImageForActivityType:(nullable NSString *)activityType
                      suggestedSize:(CGSize)size {
    return [UIImage imageNamed:@"shareFavicon"];
}

@end

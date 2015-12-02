//
//  HEMTellAFriendItemProvider.m
//  Sense
//
//  Created by Kevin MacWhinnie on 12/1/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMTellAFriendItemProvider.h"

@implementation HEMTellAFriendItemProvider

- (nonnull instancetype)initWithSubject:(nullable NSString *)subject
                              shortBody:(nonnull NSString *)shortBody
                               longBody:(nonnull NSString *)longBody {
    if ((self = [super init])) {
        _subject = [subject copy];
        _shortBody = [shortBody copy];
        _longBody = [longBody copy];
    }
    return self;
}

#pragma mark -

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return self.shortBody;
}

- (nullable id)activityViewController:(UIActivityViewController *)activityViewController
                  itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return self.longBody;
    } else {
        return self.shortBody;
    }
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
              subjectForActivityType:(nullable NSString *)activityType {
    return self.subject;
}

@end

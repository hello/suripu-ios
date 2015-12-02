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
                                   body:(nonnull NSString *)body {
    if ((self = [super init])) {
        _subject = [subject copy];
        _body = [body copy];
    }
    return self;
}

#pragma mark -

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return self.body;
}

- (nullable id)activityViewController:(UIActivityViewController *)activityViewController
                  itemForActivityType:(NSString *)activityType {
    return self.body;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
              subjectForActivityType:(nullable NSString *)activityType {
    return self.subject;
}

@end

//
//  HEMURLImageView.m
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "HEMURLImageView.h"
#import "HEMActivityIndicatorView.h"

static NSTimeInterval const HEMURLImageRequestDefaultTimeout = 30.0f;
static CGFloat const HEMURLImageActivitySize = 24.0f;

@interface HEMURLImageView()

@property (nonatomic, strong) AFHTTPRequestOperation* urlOperation;
@property (nonatomic, copy)   NSString* currentImageURL;
@property (nonatomic, weak)   HEMActivityIndicatorView* activityIndicator;

@end

@implementation HEMURLImageView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithImageURL:(NSString*)url {
    self = [super init];
    if (self) {
        [self configureDefaults];
        [self setImageWithURL:url];
    }
    return self;
}

- (void)configureDefaults {
    [self setIndicateActivity:YES];
}

- (void)setImageWithURL:(NSString*)url {
    [self setImageWithURL:url withTimeout:HEMURLImageRequestDefaultTimeout];
}

- (void)setImage:(UIImage *)image {
    // if caller is setting an image directly, without a url, then clear it
    [self setCurrentImageURL:nil];
    [super setImage:image];
}

- (void)setImageWithURL:(NSString *)url withTimeout:(NSTimeInterval)timeout {
    if ([[self currentImageURL] isEqualToString:url] && [self image]) {
        DDLogVerbose(@"image shown matches that of the current image url, skipping download");
        return;
    }
    
    // clear it, in case something is lingering and download takes a little bit
    // of time.  This will prevent it from showing a previous image if one was
    // set previously
    [self setImage:nil];
    [self cancelImageDownload];
    
    if ([url length] == 0.0f) {
        return;
    }
    
    NSURL* imageURL = [NSURL URLWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:imageURL
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:timeout];
    
    if ([self indicateActivity]) {
        [self showActivity:YES];
    }
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFImageResponseSerializer serializer]];
    
    __weak typeof(self) weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage* image) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setImage:image];
        [strongSelf setCurrentImageURL:url];
        [strongSelf showActivity:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // not sure what design wants to show in this case, but i have asked
        // and they said not to worry about it for now and just don't show
        // anything
        DDLogVerbose(@"failed to load image with url %@, with error %@", url, error);
        [weakSelf showActivity:NO];
    }];
    
    [self setUrlOperation:operation];
    [[self urlOperation] start];
}

- (void)showActivity:(BOOL)show {
    if (show) {
        if (![self activityIndicator]) {
            HEMActivityIndicatorView* activity
                = [[HEMActivityIndicatorView alloc] initWithImage:[UIImage imageNamed:@"loaderWhite"]
                                                         andFrame:[self frameForActivityIndicator]];
            [self setActivityIndicator:activity];
            [self addSubview:activity];
        }
        [[self activityIndicator] start];
    } else {
        [[self activityIndicator] stop];
    }

}

- (void)cancelImageDownload {
    if ([self urlOperation] != nil) {
        [[self urlOperation] cancel];
    }
}

- (CGRect)frameForActivityIndicator {
    CGRect frame = CGRectZero;
    CGFloat bWidth = CGRectGetWidth([self bounds]);
    CGFloat bHeight = CGRectGetHeight([self bounds]);
    CGFloat maxBound = MIN(CGRectGetWidth([self bounds]), CGRectGetHeight([self bounds]));
    CGFloat maxSize = MIN(HEMURLImageActivitySize, maxBound);
    frame.size = CGSizeMake(maxSize, maxSize);
    frame.origin.x = (bWidth - maxSize) / 2.0f;
    frame.origin.y = (bHeight - maxSize) / 2.0f;
    return frame;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self activityIndicator]) {
        [[self activityIndicator] setFrame:[self frameForActivityIndicator]];
    }
}

- (void)dealloc {
    [self cancelImageDownload];
}

@end

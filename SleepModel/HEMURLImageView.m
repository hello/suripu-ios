//
//  HEMURLImageView.m
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <AFNetworking/UIKit+AFNetworking.h>
#import "HEMURLImageView.h"
#import "HEMActivityIndicatorView.h"

static NSTimeInterval const HEMURLImageRequestDefaultTimeout = 30.0f;
static CGFloat const HEMURLImageActivitySize = 24.0f;

@interface HEMURLImageView()

@property (nonatomic, strong) AFImageDownloadReceipt* downloadReceipt;
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
    [self setImageWithURL:url withTimeout:timeout completion:nil];
}

- (void)setImageWithURL:(NSString *)url completion:(HEMURLImageCallback)completion {
    [self setImageWithURL:url
              withTimeout:HEMURLImageRequestDefaultTimeout
               completion:completion];
}

- (void)setImageWithURL:(nullable NSString *)url
            withTimeout:(NSTimeInterval)timeout
             completion:(nullable HEMURLImageCallback)completion {
    if ([[self currentImageURL] isEqualToString:url] && [self image]) {
        if (completion) {
            completion ([self image], url, nil);
        }
        return;
    }
    
    // clear it, in case something is lingering and download takes a little bit
    // of time.  This will prevent it from showing a previous image if one was
    // set previously
    [self setImage:nil];
    [self cancelImageDownload];
    
    if ([url length] == 0.0f) {
        if (completion) {
            completion (nil, url, nil);
        }
        return;
    }
    
    NSURL* imageURL = [NSURL URLWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:imageURL
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:timeout];
    [self downloadAndLoadImageFrom:request completion:completion];
}

- (void)downloadAndLoadImageFrom:(NSURLRequest*)request
                      completion:(HEMURLImageCallback)completion {
    if ([self indicateActivity]) {
        [self showActivity:YES];
    }
    
    __block NSString* url = [[request URL] absoluteString];
    __weak typeof(self) weakSelf = self;
    
    AFImageDownloader* downloader = [AFImageDownloader defaultInstance];
    [downloader downloadImageForURLRequest:request success:^(NSURLRequest * request, NSHTTPURLResponse * response, UIImage * responseObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setImage:responseObject];
        [strongSelf setCurrentImageURL:url];
        [strongSelf showActivity:NO];
        [strongSelf setDownloadReceipt:nil];
        if (completion) {
            completion (responseObject, url, nil);
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // not sure what design wants to show in this case, but i have asked
        // and they said not to worry about it for now and just don't show
        // anything
        [strongSelf showActivity:NO];
        [strongSelf setDownloadReceipt:nil];
        if (completion) {
            completion (nil, url, error);
        }
    }];
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
    if ([self downloadReceipt]) {
        [[AFImageDownloader defaultInstance] cancelTaskForImageDownloadReceipt:[self downloadReceipt]];
        [self setDownloadReceipt:nil];
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

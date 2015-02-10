//
//  HEMURLImageView.m
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "HEMURLImageView.h"

static NSTimeInterval const HEMURLImageRequestDefaultTimeout = 30.0f;

@interface HEMURLImageView()

@property (nonatomic, strong) AFHTTPRequestOperation* urlOperation;

@end

@implementation HEMURLImageView

- (instancetype)initWithImageURL:(NSString*)url {
    self = [super init];
    if (self) {
        [self setImageWithURL:url];
    }
    return self;
}

- (void)setImageWithURL:(NSString*)url {
    [self setImageWithURL:url withTimeout:HEMURLImageRequestDefaultTimeout];
}

- (void)setImageWithURL:(NSString *)url withTimeout:(NSTimeInterval)timeout {
    if ([url length] == 0) return;
    
    [self cancelImageDownload];
    
    NSURL* imageURL = [NSURL URLWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:imageURL
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:timeout];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFImageResponseSerializer serializer]];
    
    __weak typeof(self) weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage* image) {
        [weakSelf setImage:image];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // not sure what design wants to show in this case, but i have asked
        // and they said not to worry about it for now and just don't show
        // anything
        DDLogVerbose(@"failed to load image with url %@, with error %@", url, error);
    }];
    
    [self setUrlOperation:operation];
    [[self urlOperation] start];
}

- (void)cancelImageDownload {
    if ([self urlOperation] != nil) {
        [[self urlOperation] cancel];
    }
}

- (void)dealloc {
    [self cancelImageDownload];
}

@end

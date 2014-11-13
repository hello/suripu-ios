//
//  HEMAudioCache.m
//  Sense
//
//  Created by Delisa Mason on 11/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import "HEMAudioCache.h"

@interface HEMAudioCache ()<NSURLSessionDelegate>

@end

@implementation HEMAudioCache

static NSString* HEMAudioDirectory = @"audio";

+ (NSURLSession*)URLSession
{
    static NSURLSession* session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *sessionConfig =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:nil
                                           delegateQueue:nil];
    });
    return session;
}

+ (NSString*)audioCacheDirectory
{
    NSString  *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *audioCachePath = [cache stringByAppendingPathComponent:HEMAudioDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioCachePath])
        [[NSFileManager defaultManager] createDirectoryAtPath:audioCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    return audioCachePath;
}

+ (void)cacheURLforAssetAtPath:(NSString *)URLPath completion:(void (^)(NSURL *, NSError *))completion
{
    if (!completion)
        return;
    NSURL* remoteURL = [NSURL URLWithString:URLPath];
    if (!remoteURL) {
        completion(nil, nil);
        return;
    }

    NSString* fileName = [self fileNameForPath:URLPath];
    NSString* targetFilePath = [[self audioCacheDirectory] stringByAppendingPathComponent:fileName];
    NSURL* targetURL = [NSURL fileURLWithPath:targetFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:targetFilePath]) {
        completion(targetURL, nil);
        return;
    }
    [self cacheRemoteURL:remoteURL toTargetURL:targetURL completion:completion];
}

+ (NSString *)fileNameForPath:(NSString *)filePath
{
    NSCharacterSet* illegalCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/:\\?%*|\"<>"];
    return [[filePath componentsSeparatedByCharactersInSet:illegalCharacters] componentsJoinedByString:@"_"];
}

+ (void)cacheRemoteURL:(NSURL*)remoteURL toTargetURL:(NSURL*)targetURL completion:(void (^)(NSURL *, NSError *))completion
{
    NSURLSessionDownloadTask* task = [[self URLSession] downloadTaskWithURL:remoteURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        NSError* fileError = nil;
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:targetURL error:&fileError];
        if (fileError) {
            completion(nil, fileError);
            return;
        }
        completion(targetURL, nil);
    }];
    [task resume];
}

@end

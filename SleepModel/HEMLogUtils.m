//
//  HEMLogUtils.m
//  Sense
//
//  Created by Delisa Mason on 10/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <sys/utsname.h>
#import <SenseKit/SENAPIClient.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import "HEMLogUtils.h"

@implementation HEMLogUtils

static DDFileLogger* logUtilsFileLogger = nil;
static CGFloat const HEMLogUtilsRollingFrequency = 60 * 60 * 24;

+ (void)enableLogger
{
    logUtilsFileLogger = [[DDFileLogger alloc] init];
    logUtilsFileLogger.rollingFrequency = HEMLogUtilsRollingFrequency;
    logUtilsFileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:logUtilsFileLogger];
#if DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
    [self logSystemInfo];
}

+ (NSData*)latestLogFileData
{
    DDLogFileInfo* info = [logUtilsFileLogger.logFileManager.sortedLogFileInfos firstObject];
    return [NSData dataWithContentsOfFile:info.filePath];
}

+ (void)logSystemInfo
{
    UIDevice* device = [UIDevice currentDevice];
    NSString* appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *modelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    DDLogInfo(@"App started at %@", [NSDate date].description);
    DDLogInfo(@"App Version: %@", appVersion);
    DDLogInfo(@"iOS Version: %@", device.systemVersion);
    DDLogInfo(@"Device: %@", modelName);
    DDLogInfo(@"API Version: %@", [SENAPIClient baseURL]);
    if (device.batteryLevel >= 0) {
        NSString* batteryLevel = [NSString stringWithFormat:@"%0.f%%", device.batteryLevel * 100];
        DDLogInfo(@"Battery Level: %@", batteryLevel);
    }
}

@end

//
//  HEMLogUtils.m
//  Sense
//
//  Created by Delisa Mason on 10/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import "HEMLogUtils.h"

@implementation HEMLogUtils

static DDFileLogger* logUtilsFileLogger = nil;

+ (void)enableLogger
{
    logUtilsFileLogger = [[DDFileLogger alloc] init];
    logUtilsFileLogger.rollingFrequency = 60 * 60 * 24;
    logUtilsFileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:logUtilsFileLogger];
#if DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDLogVerbose(@"Added TTY logger");
#endif
}

+ (NSData*)latestLogFileData
{
    DDLogFileInfo* info = [logUtilsFileLogger.logFileManager.sortedLogFileInfos firstObject];
    return [NSData dataWithContentsOfFile:info.filePath];
}

@end

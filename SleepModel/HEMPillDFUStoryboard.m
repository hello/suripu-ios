//
// HEMPillDFUStoryboard.m
// Copyright (c) 2016 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <UIKit/UIKit.h>
#import "HEMPillDFUStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMpillDFU = @"PillDFU";
static NSString *const _HEMdfu = @"dfu";
static NSString *const _HEMpillDFUNav = @"pillDFUNav";
static NSString *const _HEMpillFinder = @"pillFinder";
static NSString *const _HEMscan = @"scan";

@implementation HEMPillDFUStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMpillDFU bundle:[NSBundle mainBundle]]); }



/** Segue Identifiers */
+(NSString *)scanSegueIdentifier { return _HEMscan; }

/** View Controllers */
+(id)instantiateDfuViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMdfu]; }
+(id)instantiatePillDFUNavViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillDFUNav]; }
+(id)instantiatePillFinderViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillFinder]; }

@end

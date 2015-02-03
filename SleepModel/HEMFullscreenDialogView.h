//
//  HEMFullscreenDialogView.h
//  Sense
//
//  Created by Delisa Mason on 1/27/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMDialogContent : NSObject
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) UIImage* image;
@end

@interface HEMFullscreenDialogView : UIView

/**
 *  Present an array of HEMDialogContent objects as modal dialogs
 *  with a page control if the number of dialogs is greater than 1
 *
 *  @param contents array of content objects
 */
+ (void)showDialogsWithContent:(NSArray *)contents;

@end

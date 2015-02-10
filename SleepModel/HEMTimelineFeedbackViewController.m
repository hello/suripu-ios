//
//  HEMTimelineFeedbackViewController.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSleepResult.h>
#import "HEMTimelineFeedbackViewController.h"
#import "HEMClockPickerView.h"

@interface HEMTimelineFeedbackViewController ()
@property (nonatomic, weak) IBOutlet HEMClockPickerView* clockView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@end

@implementation HEMTimelineFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // update clock picker time to segment time
    // set title from segment event type
}

- (IBAction)sendUpdatedTime:(id)sender
{

}

- (IBAction)cancelAndDismiss:(id)sender
{
    
}

@end

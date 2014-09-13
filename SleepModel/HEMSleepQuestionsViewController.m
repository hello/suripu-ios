//
//  HEMSleepQuestionsViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <iCarousel/iCarousel.h>

#import <SenseKit/SENQuestion.h>
#import <SenseKit/SENAnswer.h>
#import <SenseKit/SENServiceQuestions.h>

#import "HEMSleepQuestionsViewController.h"
#import "HEMActionButton.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"

@interface HEMSleepQuestionsViewController () <iCarouselDataSource, iCarouselDelegate>

@property (weak, nonatomic) IBOutlet UILabel* questionLabel;
@property (weak, nonatomic) IBOutlet iCarousel* answerCarousel;
@property (weak, nonatomic) IBOutlet HEMActionButton* submitButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (strong, nonatomic) SENQuestion* question;

@end

@implementation HEMSleepQuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSInteger countOfQuestions = [[self questions] count];
    if (countOfQuestions > 0 && [self questionIndex] < countOfQuestions) {
        [self setQuestion:[self questions][[self questionIndex]]];
        [[self questionLabel] setText:[[self question] question]];
    }

    [self setupAnswerCarousel];
}

- (void)setupAnswerCarousel {
    iCarouselType type = [self typeForCount:[[[self question] choices] count]];
    [[self answerCarousel] setType:type];
    [[self answerCarousel] setDataSource:self];
    [[self answerCarousel] setDelegate:self];
    [[self answerCarousel] reloadData];
    [[self answerCarousel] setBounces:NO];
    [[self answerCarousel] setClipsToBounds:YES];
}

- (iCarouselType)typeForCount:(NSInteger)count {
    iCarouselType type = iCarouselTypeLinear;
    if (count > 3) {
        type = iCarouselTypeWheel;
    }
    return type;
}

#pragma mark - iCarousel

- (NSUInteger)numberOfItemsInCarousel:(iCarousel*)carousel {
    return [[[self question] choices] count];
}

- (UIView *)carousel:(__unused iCarousel *)carousel
  viewForItemAtIndex:(NSUInteger)index
         reusingView:(UIView *)view {
    
    UILabel* choiceLabel = nil;
    
    if (view == nil) {
        CGRect frame = {0.0f, 0.0f, 100.0f, 100.0f};
        choiceLabel = [[UILabel alloc] initWithFrame:frame];
        [choiceLabel setTextAlignment:NSTextAlignmentCenter];
        [choiceLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]];
        [choiceLabel setTextColor:[HelloStyleKit mediumBlueColor]];
    } else {
        choiceLabel = (UILabel*)view;
    }
    
    SENAnswer* answer = [[self question] choices][index];
    [choiceLabel setText:[answer answer]];
    
    return choiceLabel;
}

- (CGFloat)carousel:(iCarousel *)carousel
     valueForOption:(iCarouselOption)option
        withDefault:(CGFloat)value {
    if ([carousel type] != iCarouselTypeWheel) {
        return value;
    }

    switch (option) {
        case iCarouselOptionSpacing:
            return 3.0f;
        case iCarouselOptionVisibleItems:
            return 3.0f;
        case iCarouselOptionRadius:
            return value * 0.5f; // take half the radius to move items closer
        case iCarouselOptionArc:
            return M_PI; // half a circle
        case iCarouselOptionAngle:
            return ((45.0f) / 180.0 * M_PI); // 45degs approximately between items
        default:
            return value;
    }
}

#pragma mark - Actions

- (void)showActivity:(BOOL)show {
    if (show) {
        [[self submitButton] showActivity];
    } else {
        [[self submitButton] stopActivity];
    }
    
    [[self skipButton] setEnabled:!show];
    [[self answerCarousel] setScrollEnabled:!show];
}

- (void)showError:(__unused NSError*)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"questions.failed.title", nil)
                                message:NSLocalizedString(@"questions.error.unexpected", nil)
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil] show];
}

- (IBAction)skip:(id)sender {
    [[SENServiceQuestions sharedService] setQuestionsAskedToday];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submit:(id)sender {
    [self showActivity:YES];

    NSInteger selectedIndex = [[self answerCarousel] currentItemIndex];
    SENAnswer* answer = [[[self question] choices] objectAtIndex:selectedIndex];
    SENServiceQuestions* service = [SENServiceQuestions sharedService];
    
    __weak typeof(self) weakSelf = self;
    [service submitAnswer:answer completion:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf showActivity:NO];
            
            if (error == nil) {
                NSInteger nextQIndex = [strongSelf questionIndex]+1;
                if (nextQIndex < [[strongSelf questions] count]) {
                    [strongSelf toNextQuestionAtIndex:nextQIndex];
                } else {
                    [strongSelf dismissViewControllerAnimated:YES completion:nil];
                }
            } else {
                [strongSelf showError:error];
            }
            
        }
    }];
    
}

- (void)toNextQuestionAtIndex:(NSInteger)nextQIndex {
    HEMSleepQuestionsViewController* nextQuestionVC =
        (HEMSleepQuestionsViewController*)[HEMMainStoryboard instantiateSleepQuestionsViewController];
    [nextQuestionVC setQuestions:[self questions]];
    [nextQuestionVC setQuestionIndex:nextQIndex];
    [[self view] setHidden:YES];
    [[self navigationController] setViewControllers:@[nextQuestionVC] animated:YES];
}

@end

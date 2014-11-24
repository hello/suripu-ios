//
//  HEMSleepQuestionsViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENQuestion.h>
#import <SenseKit/SENAnswer.h>
#import <SenseKit/SENServiceQuestions.h>

#import "UIFont+HEMStyle.h"

#import "HEMSleepQuestionsViewController.h"
#import "HEMActionButton.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMAnimationUtils.h"
#import "HEMAlertController.h"

static CGFloat const kHEMSleepAnswerButtonBorderWidth = 1.0f;
static CGFloat const kHEMSleepAnswerButtonHeight = 50.0f;
static CGFloat const kHEMSleepAnswerSpacing = 15.0f;
static CGFloat const kHEMSleepViewAnimDuration = 0.2f;
static CGFloat const kHEMSleepAnswerDisplayDelay = 0.2f;
static CGFloat const kHEMSleepWordDisplayDelay = 0.2f;

@interface HEMSleepQuestionsViewController ()

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIView* titleSeparator;
@property (weak, nonatomic) IBOutlet UILabel* questionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView* choicesScrollView;
@property (weak, nonatomic) IBOutlet UIButton* skipButton;
@property (weak, nonatomic) IBOutlet UILabel* thankLabel;
@property (weak, nonatomic) IBOutlet UILabel* youLabel;
@property (assign, nonatomic) NSInteger questionIndex;

@property (strong, nonatomic) SENQuestion* currentQuestion;
@property (strong, nonatomic) CALayer* activityLayer;

@end

@implementation HEMSleepQuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFonts];
    [self setQuestionIndex:0];
    [self setupBackgroundImage];
    [self displayQuestionAtIndex:[self questionIndex]];
}

- (void)configureFonts {
    [[self titleLabel] setFont:[UIFont questionTitleFont]];
    [[self questionLabel] setFont:[UIFont questionFont]];
    [[self thankLabel] setFont:[UIFont thankyouFont]];
    [[self youLabel] setFont:[UIFont thankyouFont]];
    [[[self skipButton] titleLabel] setFont:[UIFont questionAnswerFont]];
}

- (void)setupBackgroundImage {
    if ([self bgImage] != nil) {
        UIImageView* bgImageView = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
        [bgImageView setImage:[self bgImage]];
        [bgImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                                         | UIViewAutoresizingFlexibleHeight];
        [bgImageView setTranslatesAutoresizingMaskIntoConstraints:YES];

        [[self view] insertSubview:bgImageView atIndex:0];
    }
}

- (void)displayQuestionAtIndex:(NSInteger)index {
    if (index >= [[self questions] count])
        return;

    SENQuestion* question = [self questions][index];
    [self setCurrentQuestion:question];
    // display the question text
    [[self questionLabel] setText:[question question]];
    [[self questionLabel] setNeedsLayout];

    CGRect buttonFrame = CGRectZero;
    buttonFrame.origin.x = kHEMSleepAnswerButtonBorderWidth;
    buttonFrame.size.width = CGRectGetWidth([[self choicesScrollView] bounds])-(kHEMSleepAnswerButtonBorderWidth*2);
    buttonFrame.size.height = kHEMSleepAnswerButtonHeight;

    NSArray* answerChoices = [question choices];
    UIButton* choiceButton = nil;
    NSInteger tag = 0;
    for (SENAnswer* choice in answerChoices) {
        choiceButton = [self buttonForAnswer:choice withFrame:buttonFrame];
        [choiceButton setTag:tag++];
        [[self choicesScrollView] addSubview:choiceButton];
        buttonFrame.origin.y = CGRectGetMaxY(buttonFrame) + kHEMSleepAnswerSpacing;
    }

    CGSize contentSize = [[self choicesScrollView] contentSize];
    contentSize.height = CGRectGetMinY(buttonFrame);
    [[self choicesScrollView] setContentSize:contentSize];
}

- (UIButton*)buttonForAnswer:(SENAnswer*)answer withFrame:(CGRect)frame {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [button setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    [button addTarget:self
                  action:@selector(selectAnswer:)
        forControlEvents:UIControlEventTouchUpInside];

    [button setTitle:[answer answer] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont questionAnswerFont]];

    [[button layer] setCornerRadius:kHEMSleepAnswerButtonHeight / 2];
    [[button layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[button layer] setBorderWidth:kHEMSleepAnswerButtonBorderWidth];

    [button setFrame:frame];
    [button setTransform:CGAffineTransformMakeScale(0.9f, 0.9f)];
    [button setAlpha:0.0f];

    return button;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateIn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)showActivityOn:(UIButton*)button {
    if ([self activityLayer] != nil) [[self activityLayer] removeFromSuperlayer];
    [self setActivityLayer:[HEMAnimationUtils animateActivityAround:button]];
}

- (void)stopActivity {
    [[self activityLayer] removeFromSuperlayer];
    [self setActivityLayer:nil];
}

- (void)animateIn {
    NSInteger index = 0;
    for (UIView* subview in [[self choicesScrollView] subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [UIView animateWithDuration:kHEMSleepViewAnimDuration
                                  delay:kHEMSleepAnswerDisplayDelay * index
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [subview setAlpha:1.0f];
                                 [subview setTransform:CGAffineTransformIdentity];
                             }
                             completion:nil];
            index++;
        }
    }
}

- (void)animateOut {
    [[self activityLayer] removeFromSuperlayer];
    [UIView animateWithDuration:kHEMSleepViewAnimDuration
                     animations:^{
                         [[self titleLabel] setAlpha:0.0f];
                         [[self titleSeparator] setAlpha:0.0f];
                         [[self questionLabel] setAlpha:0.0f];
                         [[self choicesScrollView] setAlpha:0.0f];
                         [[self skipButton] setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [self aniamteThankyou];
                     }];
}

- (void)aniamteThankyou {
    [[self thankLabel] setHidden:NO];
    [[self youLabel] setHidden:NO];
    [UIView animateWithDuration:kHEMSleepViewAnimDuration
                     animations:^{
                         [[self thankLabel] setAlpha:1.0f];
                     }];
    [UIView animateWithDuration:kHEMSleepViewAnimDuration
                          delay:kHEMSleepWordDisplayDelay
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [[self youLabel] setAlpha:1.0f];
                         [self performSelector:@selector(dismiss)
                                    withObject:nil
                                    afterDelay:1.0f];
                     }
                     completion:nil];
}



#pragma mark - Actions

- (void)showError:(__unused NSError*)error {
    [HEMAlertController presentInfoAlertWithTitle:NSLocalizedString(@"questions.failed.title", nil)
                                          message:NSLocalizedString(@"questions.error.unexpected", nil)
                             presentingController:self];
}

- (void)enableAnswerButtons:(BOOL)enable except:(UIButton*)choiceButton {
    for (UIView* subview in [[self choicesScrollView] subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton* button = (UIButton*)subview;

            [button setEnabled:enable];

            if (subview == choiceButton) {
                [button setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:enable ? 0.0f : 0.1f]];
            } else {
                [button setAlpha:enable ? 1.0f : 0.3f];
            }
        }
    }
}

- (void)selectAnswer:(UIButton*)choiceButton {
    NSInteger index = [choiceButton tag];
    SENAnswer* answer = [[self currentQuestion] choices][index];

    [self showActivityOn:choiceButton];
    [self enableAnswerButtons:NO except:choiceButton];
    
    SENServiceQuestions* service = [SENServiceQuestions sharedService];

    __weak typeof(self) weakSelf = self;
    [service submitAnswer:answer completion:^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            
            [strongSelf stopActivity];
            
            if (error == nil) {
                NSInteger nextQIndex = [strongSelf questionIndex]+1;
                if (nextQIndex < [[strongSelf questions] count]) {
                    // TODO (jimmy): support multiple questions per day.  Design
                    // is still thinking about how this will work, UX wise.
                    [strongSelf animateOut];
                } else {
                    [strongSelf animateOut];
                }
            } else {
                [strongSelf enableAnswerButtons:YES except:choiceButton];
                [strongSelf showError:error];
            }
            
        }
    }];
}

- (IBAction)skip:(id)sender {
    // optimistically skip the question
    SENServiceQuestions* svc = [SENServiceQuestions sharedService];
    [svc skipQuestion:[self currentQuestion] completion:nil];
    [self dismiss];
}

#pragma mark - Navigation

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

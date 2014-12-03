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
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMAnimationUtils.h"
#import "HEMSleepQuestionsDataSource.h"
#import "HEMAnswerCell.h"

static CGFloat const kHEMSleepViewAnimDuration = 0.2f;
static CGFloat const kHEMSleepWordDisplayDelay = 0.2f;

@interface HEMSleepQuestionsViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *answerTableView;
@property (weak, nonatomic) IBOutlet UILabel* questionLabel;
@property (weak, nonatomic) IBOutlet UIButton* skipButton;
@property (weak, nonatomic) IBOutlet UILabel* thankLabel;
@property (weak, nonatomic) IBOutlet UILabel* youLabel;

@property (strong, nonatomic) SENQuestion* currentQuestion;
@property (strong, nonatomic) CALayer* activityLayer;

@end

@implementation HEMSleepQuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    
    [self setupBackgroundImage];
    [self configure];
}

- (void)configure {
    [[self questionLabel] setFont:[UIFont questionFont]];
    [[self thankLabel] setFont:[UIFont thankyouFont]];
    [[self youLabel] setFont:[UIFont thankyouFont]];
    [[[self skipButton] titleLabel] setFont:[UIFont questionAnswerFont]];
    
    if ([self dataSource] == nil) {
        [self setDataSource:[[HEMSleepQuestionsDataSource alloc] init]];
    }
    
    [[self questionLabel] setText:[[self dataSource] selectedQuestionText]];
    
    CGRect questionFrame = [[self questionLabel] frame];
    CGSize constraint = questionFrame.size;
    constraint.height = MAXFLOAT;
    questionFrame.size.height = [[self questionLabel] sizeThatFits:constraint].height;
    [[self questionLabel] setFrame:questionFrame];
    
    [[self answerTableView] setDataSource:[self dataSource]];
    [[self answerTableView] setDelegate:self];
    [[self answerTableView] setTableFooterView:[[UIView alloc] init]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self answerTableView] flashScrollIndicators];
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

- (void)showActivityOn:(UIButton*)button {
    if ([self activityLayer] != nil) [[self activityLayer] removeFromSuperlayer];
    [self setActivityLayer:[HEMAnimationUtils animateActivityAround:button]];
}

- (void)stopActivity {
    [[self activityLayer] removeFromSuperlayer];
    [self setActivityLayer:nil];
}

- (void)animateOut {
    [[self activityLayer] removeFromSuperlayer];
    [UIView animateWithDuration:kHEMSleepViewAnimDuration
                     animations:^{
                         [[self questionLabel] setAlpha:0.0f];
                         [[self skipButton] setAlpha:0.0f];
                         [[self answerTableView] setAlpha:0.0f];
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


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMAnswerCell* answerCell = (HEMAnswerCell*)cell;
    NSString* text = [[[self dataSource] answerTextAtIndexPath:indexPath] uppercaseString];
    [[answerCell answerLabel] setText:text];
    [[answerCell separator] setHidden:[[self dataSource] isIndexPathLast:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[self dataSource] selectAnswerAtIndexPath:indexPath]) {
        [self animateOut];
    } else {
        [self toNextQuestion];
    }
}


#pragma mark - Actions

- (IBAction)skip:(id)sender {
    if (![[self dataSource] skipQuestion]) {
        [self dismiss];
    } else {
        [self toNextQuestion];
    }
    
}

#pragma mark - Navigation

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toNextQuestion {
    [[self dataSource] nextQuestion];
    
    HEMSleepQuestionsViewController* questionVC
        = (HEMSleepQuestionsViewController*)[HEMMainStoryboard instantiateSleepQuestionsViewController];
    [questionVC setBgImage:[self bgImage]];
    [questionVC setDataSource:[self dataSource]];
    
    [[self navigationController] pushViewController:questionVC animated:YES];
}

@end

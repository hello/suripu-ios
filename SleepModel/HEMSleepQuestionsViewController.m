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
#import "HEMSingleResponseCell.h"
#import "HEMMultipleResponseCell.h"

static CGFloat const kHEMSleepViewAnimDuration = 0.2f;

@interface HEMSleepQuestionsViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *answerTableView;
@property (weak, nonatomic) IBOutlet UILabel* questionLabel;
@property (weak, nonatomic) IBOutlet UIButton* skipButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;

@property (strong, nonatomic) SENQuestion* currentQuestion;
@property (strong, nonatomic) CALayer* activityLayer;
@property (strong, nonatomic) NSMutableSet* selectedAnswerPaths; // for multi selections only

@end

@implementation HEMSleepQuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    
    [self setupBackgroundImage];
    [self configure];
    
    [SENAnalytics track:kHEMAnalyticsEventQuestion];
}

- (void)configure {
    [[self questionLabel] setFont:[UIFont questionFont]];
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
    
    BOOL multiple = [[self dataSource] allowMultipleSelectionForSelectedQuestion];
    if (multiple) {
        [self setSelectedAnswerPaths:[NSMutableSet set]];
    }
    [[self answerTableView] setAllowsMultipleSelection:multiple];
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
                         [self dismiss];
                     }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* text = [[[self dataSource] answerTextAtIndexPath:indexPath] uppercaseString];
    BOOL isLastCell = [[self dataSource] isIndexPathLast:indexPath];
    
    if ([cell isKindOfClass:[HEMSingleResponseCell class]]) {
        HEMSingleResponseCell* answerCell = (HEMSingleResponseCell*)cell;

        [[answerCell answerLabel] setText:text];
        [[answerCell separator] setHidden:isLastCell];
    } else if ([cell isKindOfClass:[HEMMultipleResponseCell class]]) {
        HEMMultipleResponseCell* multiCell = (HEMMultipleResponseCell*)cell;
        
        BOOL selected = [[self selectedAnswerPaths] containsObject:indexPath];
        [multiCell setSelected:selected];
        [[multiCell answerLabel] setText:text];
        [[multiCell separator] setHidden:isLastCell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![tableView allowsMultipleSelection]) {
        if (![[self dataSource] selectAnswerAtIndexPath:indexPath]) {
            [self animateOut];
        } else {
            [self toNextQuestion];
        }
    } else {
        [[self selectedAnswerPaths] addObject:[indexPath copy]];
        [self updateButtonsBasedOnSelection];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView allowsMultipleSelection]) {
        [[self selectedAnswerPaths] removeObject:indexPath];
        [self updateButtonsBasedOnSelection];
    }
}

- (void)updateButtonsBasedOnSelection {
    BOOL hasSelectedAnswers = [[self selectedAnswerPaths] count]>0;
    [[self doneButton] setHidden:!hasSelectedAnswers];
    [[self skipButton] setHidden:hasSelectedAnswers];
}


#pragma mark - Actions

- (IBAction)skip:(id)sender {
    if (![[self dataSource] skipQuestion]) {
        [self dismiss];
    } else {
        [self toNextQuestion];
    }
}

- (IBAction)done:(id)sender {
    if (![[self dataSource] selectAnswersAtIndexPaths:[self selectedAnswerPaths]]) {
        [self animateOut];
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

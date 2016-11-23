//
//  HEMSleepQuestionsViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENQuestion.h>
#import <SenseKit/SENAnswer.h>

#import "UIFont+HEMStyle.h"

#import "HEMSleepQuestionsViewController.h"
#import "HEMActionButton.h"
#import "HEMMainStoryboard.h"
#import "HEMAnimationUtils.h"
#import "HEMSleepQuestionsDataSource.h"
#import "HEMSingleResponseCell.h"
#import "HEMMultipleResponseCell.h"
#import "HEMUnreadAlertService.h"

@interface HEMSleepQuestionsViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *answerTableView;
@property (weak, nonatomic) IBOutlet UILabel* questionLabel;
@property (weak, nonatomic) IBOutlet UIButton* skipButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;

@property (strong, nonatomic) HEMUnreadAlertService* unreadService;
@property (strong, nonatomic) SENQuestion* currentQuestion;
@property (strong, nonatomic) NSMutableSet* selectedAnswerPaths; // for multi selections only

@end

@implementation HEMSleepQuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // TODO (jimmy): probably should find a better way to hide the chevron
    // back image when using the custom navigtion controller.  It also should
    // not show a chevron on the first controller, which is currently what is
    // doing.  In case the the navigation controller is switched back to a
    // vanilla one, i am leaving the call to hide back button here
    [[self navigationItem] setLeftBarButtonItem:nil];
    [[self navigationItem] setHidesBackButton:YES];
    
    [self setupBackgroundImage];
    [self configure];
    
    [SENAnalytics track:kHEMAnalyticsEventQuestion];
}

- (void)configure {
    [self setUnreadService:[HEMUnreadAlertService new]];
    
    [[self questionLabel] setFont:[UIFont h4]];
    [[[self skipButton] titleLabel] setFont:[UIFont h6Bold]];
    
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
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (![[self dataSource] selectAnswerAtIndexPath:indexPath]) {
            [self dismiss];
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
        [self dismiss];
    } else {
        [self toNextQuestion];
    }
}

#pragma mark - Navigation

- (void)dismiss {
    BOOL implementsAction = [[self dataSource] respondsToSelector:@selector(takeActionBeforeDismissingFrom:)];
    if (!implementsAction || ![[self dataSource] takeActionBeforeDismissingFrom:self]) {
        
        [[self unreadService] updateLastViewFor:HEMUnreadTypeQuestions completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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

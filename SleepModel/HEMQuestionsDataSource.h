//
//  HEMQuestionsDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 7/30/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HEMQuestionsDataSource <NSObject, UITableViewDataSource>

@required
/**
 * Current selected question text, if a question is available at current selected
 * index.  Index defaults to zero unless advanced by nextQuestion
 *
 * @return text of the question or nil
 */
- (NSString*)selectedQuestionText;

/**
 * @return YES if current question is a checkbox type, meaning that multiple answers
 *         are allowed.  Returns NO otherwise
 */
- (BOOL)allowMultipleSelectionForSelectedQuestion;

/**
 * The text of the answer at the specified index path, if it maps to one
 *
 * @param indexPath: the path of the row in the table view
 * @return           text of the answer or nil
 */
- (NSString*)answerTextAtIndexPath:(NSIndexPath*)indexPath;

/**
 * Advance to the next question in today's set of questions.  Since this object
 * is intended to be passed along, make sure to call this method and pass it along
 * to the next question controller
 */
- (void)nextQuestion;

/**
 * Skip the currently displayed question, specified by the selectedQuestionIndex
 *
 * @return YES if there are more questions after skipping.  Caller should proceed to next
 */
- (BOOL)skipQuestion;

/**
 * Select the answer at the tableview's index path
 *
 * @param indexPath: the tableview's indexPath that is selected
 * @return           YES if there are more questions.  Caller should proceed to next
 */
- (BOOL)selectAnswerAtIndexPath:(NSIndexPath*)indexPath;

/**
 * Select 1 or more answers to the currently selected question by providing a
 * set of NSIndexPath objects that corresponding to the tableview's indexPaths
 *
 * @param indexPaths: an array of NSIndexPath that have been selected
 * @return            YES if there are more questions.  Caller should proceed to next
 */
- (BOOL)selectAnswersAtIndexPaths:(NSSet*)indexPaths;

/**
 * Is the specified indexPath the last in the list?
 *
 * @return YES if last, NO otherwise
 */
- (BOOL)isIndexPathLast:(NSIndexPath*)indexPath;

@optional
/**
 * Called by the controller, specified by the argument, to allow data source to
 * take an action before dismissing.
 * 
 * @param controller: controller managing the data source
 * @return            YES to take action, in which controller will dismiss once
 *                    it appears again from a call to viewDidAppear: or NO to
 *                    dismiss immmediately
 */
- (BOOL)takeActionBeforeDismissingFrom:(UIViewController*)controller;

@end

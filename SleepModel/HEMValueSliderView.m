//
//  HEMValueSliderView.m
//  Sense
//
//  Created by Jimmy Lu on 8/21/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "HEMValueSliderView.h"
#import "HelloStyleKit.h"

static NSInteger const kHEMValueSliderTagValueLabel = 10;
static CGFloat const kHEMValueSliderValueCellHeight = 75.0f;

@interface HEMValueSliderView() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* valuesTableView;
@property (nonatomic, assign) NSInteger numberOfValues;

@end

@implementation HEMValueSliderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UITableView* tv = [[UITableView alloc] initWithFrame:[self bounds]];
    [tv setDelegate:self];
    [tv setDataSource:self];
    [tv setBackgroundColor:[UIColor clearColor]];
    [tv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tv setShowsVerticalScrollIndicator:NO];
    [tv setShowsHorizontalScrollIndicator:NO];
    [tv setBounces:NO];
    
    [self setValuesTableView:tv];
    [self addSubview:[self valuesTableView]];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)drawRect:(CGRect)rect {
    CGFloat lineWidth = 1.0f;
    CGFloat lineSize = 30.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [[HelloStyleKit onboardingBlueColor] CGColor]);
    CGContextSetLineWidth(context, lineWidth);
    
    // add a line at the middle of the view
    CGFloat bWidth = CGRectGetWidth([self bounds]);
    CGFloat bHeight = CGRectGetHeight([self bounds]);
    CGFloat y = (bHeight/2)-(lineWidth/2.0f);
    CGContextMoveToPoint(context, bWidth-lineSize, y);
    CGContextAddLineToPoint(context, bWidth, y);
    
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self setNumberOfValues:[[self delegate] numberOfRowsInSliderView:self]];
    return [self numberOfValues] + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    if ([indexPath row] > 0 && [indexPath row] <= [self numberOfValues]) {
        height = kHEMValueSliderValueCellHeight;
    } else {
        height = ceilf((CGRectGetHeight([tableView bounds])/2)-(kHEMValueSliderValueCellHeight/2));
    }
    return height;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"value";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellId];
        
        CGRect labelFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth([tableView bounds])-6.0f, kHEMValueSliderValueCellHeight);
        UILabel* valueLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [valueLabel setTextAlignment:NSTextAlignmentRight];
        [valueLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
        [valueLabel setTextColor:[UIColor blackColor]];
        [valueLabel setTag:kHEMValueSliderTagValueLabel];
        
        [[cell contentView] addSubview:valueLabel];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[cell contentView] setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    UILabel* valueLabel = (UILabel*)[[cell contentView] viewWithTag:kHEMValueSliderTagValueLabel];
    NSString* text = nil;
    CGFloat textAlpha = 1.0f;
    if ([indexPath row] > 0 && [indexPath row] <= [self numberOfValues]) {
        NSNumber* value = [[self delegate] sliderView:self numberForRow:[indexPath row]-1];
        text = [value stringValue];
    }
    [valueLabel setTextColor:[[valueLabel textColor] colorWithAlphaComponent:textAlpha]];
    [valueLabel setText:text];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([[self delegate] respondsToSelector:@selector(sliderView:didScrollToValue:)]) {
        NSInteger topRow = (int)floorf([scrollView contentOffset].y);
        NSNumber* value = [[self delegate] sliderView:self numberForRow:topRow];
        CGFloat remainder = [scrollView contentOffset].y - (topRow * kHEMValueSliderValueCellHeight);
        CGFloat inc = [[self delegate] incrementalValuePerRowInSliderView:self];
        CGFloat preciseValue = [value floatValue]+(inc*(remainder/kHEMValueSliderValueCellHeight));
        [[self delegate] sliderView:self didScrollToValue:preciseValue];
    }
}

#pragma mark - Public Interfaces

- (void)reload {
    [[self valuesTableView] reloadData];
}

- (void)setToValue:(float)value {
    CGPoint offset = [[self valuesTableView] contentOffset];
    offset.y = value*kHEMValueSliderValueCellHeight;
    [[self valuesTableView] setContentOffset:offset];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[self valuesTableView] setDelegate:nil];
    [[self valuesTableView] setDataSource:nil];
}

@end


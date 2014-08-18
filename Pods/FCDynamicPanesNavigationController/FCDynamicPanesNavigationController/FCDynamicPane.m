//
//  FCDynamicPane.m
//
//  Created by Florent Crivello on 3/18/14.
//

#import "FCDynamicPane.h"
#import "FCDynamicPanesNavigationController.h"

@interface FCDynamicPane () <UIGestureRecognizerDelegate> {
    BOOL _isOutOfScreen;
}

@property (nonatomic) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic) UITapGestureRecognizer* tapGestureRecognizer;
@property (nonatomic) FCDynamicPanesNavigationController* panesNavigationController;

@end

@implementation FCDynamicPane

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _swipeEnabled = YES;
    return self;
}

- (instancetype)initWithViewController:(UIViewController*)viewController
{
    self = [self init];
    if (!self) {
        return nil;
    }
    _viewController = viewController;
    return self;
}

- (void)dealloc
{
    _panGestureRecognizer.delegate = nil;
    _panGestureRecognizer = nil;
}

#pragma mark - Gestures

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UISwipeGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}

- (void)tapHandle:(UITapGestureRecognizer*)gesture
{
    if (self.state != FCDynamicPaneStateRoot) {
        [self.pushBehavior setPushDirection:CGVectorMake(0, -500)];
        self.pushBehavior.active = YES;
    }
}

- (void)panHandle:(UIPanGestureRecognizer*)gesture
{
    if (self.state == FCDynamicPaneStateRoot || !self.swipeEnabled) {
        return;
    }

    CGPoint newLocation = CGPointMake(self.view.layer.anchorPoint.x * self.view.bounds.size.width, [gesture locationInView:self.view.superview].y);
    newLocation.y = MAX(newLocation.y, self.view.layer.anchorPoint.y * self.view.bounds.size.height);

    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint anchor = [gesture locationInView:gesture.view];
        [self setAnchorPoint:CGPointMake(anchor.x / gesture.view.bounds.size.width,
                                         anchor.y / gesture.view.bounds.size.height)];

        self.pushBehavior.active = NO;
        [self.behavior removeChildBehavior:self.attachmentBehavior];
        [self.animator removeBehavior:self.behavior];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        self.view.layer.position = newLocation;
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self setAnchorPoint:CGPointMake(0.5, 0.5)];

        //I think that's a bug in the SDK, the collision behavior keeps losing its points
        [self.collisionBehavior addBoundaryWithIdentifier:@"collision" fromPoint:CGPointMake(0, -1) toPoint:CGPointMake(320, -1)];

        CGFloat pushDirectionY = [gesture velocityInView:self.view].y;
        [self.pushBehavior setPushDirection:CGVectorMake(0, pushDirectionY)];
        self.pushBehavior.active = YES;

        [self.behavior addChildBehavior:self.pushBehavior];
        [self.animator addBehavior:self.behavior];
    }
}

#pragma mark - Events

- (void)willMoveToParentViewController:(UIViewController*)parent
{
    [super willMoveToParentViewController:parent];
    [self addChildViewController:_viewController];
    [self.view addSubview:_viewController.view];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    self.tapGestureRecognizer.cancelsTouchesInView = NO;

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
    self.panGestureRecognizer.cancelsTouchesInView = NO;
    [_viewController.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)didMoveToParentViewController:(UIViewController*)parent
{
    [super didMoveToParentViewController:parent];
    [_viewController didMoveToParentViewController:self];
    _isOutOfScreen = [self.view.superview convertPoint:self.view.frame.origin toView:nil].y > [UIScreen mainScreen].bounds.size.height;

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:[self.view superview]];

    self.behavior = [[UIDynamicBehavior alloc] init];
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[ self.view ]];
    [self.collisionBehavior addBoundaryWithIdentifier:@"collision" fromPoint:CGPointMake(0, -1) toPoint:CGPointMake(320, -1)];
    [self.behavior addChildBehavior:self.collisionBehavior];

    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[ self.view ]];
    __weak FCDynamicPane* weakSelf = self;
    self.gravityBehavior.action = ^{
		typeof(self) strongSelf = weakSelf;
		
		BOOL isOutOfScreenNow = [strongSelf.view.superview convertPoint:weakSelf.view.frame.origin toView:nil].y > [UIScreen mainScreen].bounds.size.height;
		if (isOutOfScreenNow && !strongSelf->_isOutOfScreen) {
			if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(dynamicPaneDidGoOutOfScreen:)]) {
				[strongSelf.delegate dynamicPaneDidGoOutOfScreen:weakSelf];
			}
		}
		
		strongSelf->_isOutOfScreen = isOutOfScreenNow;
		
		if (strongSelf.view.frame.origin.y <= 50) {
			strongSelf.attachmentBehavior.anchorPoint = CGPointMake(160, [UIScreen mainScreen].bounds.size.height / 2-10);
			strongSelf.attachmentBehavior.damping = 0.7f;
			strongSelf.attachmentBehavior.frequency = 2.0f;
			[strongSelf.behavior addChildBehavior:strongSelf.attachmentBehavior];
            strongSelf.state = FCDynamicPaneStateActive;
		} else if (strongSelf.view.frame.origin.y >= TILE_Y-60) {
			strongSelf.attachmentBehavior.anchorPoint = CGPointMake(160, [UIScreen mainScreen].bounds.size.height / 2+TILE_Y);
			strongSelf.attachmentBehavior.damping = 0.4f;
			strongSelf.attachmentBehavior.frequency = 4.0f;
			[strongSelf.behavior addChildBehavior:strongSelf.attachmentBehavior];
            strongSelf.state = FCDynamicPaneStateRetracted;
		}
    };
    [self.behavior addChildBehavior:self.gravityBehavior];

    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.view attachedToAnchor:CGPointMake(160, TILE_Y + [UIScreen mainScreen].bounds.size.height / 2)];
    self.attachmentBehavior.frequency = 4.0f;
    self.attachmentBehavior.damping = 0.4f;
    self.attachmentBehavior.length = 0;

    UIDynamicItemBehavior* dynamicView = [[UIDynamicItemBehavior alloc] initWithItems:@[ self.view ]];
    dynamicView.density = 3.0f;
    dynamicView.elasticity = 0;
    dynamicView.allowsRotation = NO;
    [self.behavior addChildBehavior:dynamicView];

    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[ self.view ] mode:UIPushBehaviorModeInstantaneous];
    [self.behavior addChildBehavior:self.pushBehavior];

    [self.animator addBehavior:self.behavior];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint newPoint = CGPointMake(self.view.bounds.size.width * anchorPoint.x, self.view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(self.view.bounds.size.width * self.view.layer.anchorPoint.x, self.view.bounds.size.height * self.view.layer.anchorPoint.y);

    newPoint = CGPointApplyAffineTransform(newPoint, self.view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, self.view.transform);

    CGPoint position = self.view.layer.position;

    position.x -= oldPoint.x;
    position.x += newPoint.x;
    position.y -= oldPoint.y;
    position.y += newPoint.y;

    self.view.layer.position = position;
    self.view.layer.anchorPoint = anchorPoint;
}

- (void)setState:(FCDynamicPaneState)state
{
    if (state == FCDynamicPaneStateRoot) {
        self.swipeEnabled = NO;
    }

    if (state == _state) {
        return;
    }

    if (state == FCDynamicPaneStateRoot) {
        self.gravityBehavior.gravityDirection = CGVectorMake(0, -1.5);
        __weak FCDynamicPane* weakSelf = self;
        self.gravityBehavior.action = ^{
			typeof(self) strongSelf = weakSelf;
			if (strongSelf.view.frame.origin.y <= 10) {
				strongSelf.attachmentBehavior.anchorPoint = CGPointMake(160, [UIScreen mainScreen].bounds.size.height / 2);
				strongSelf.attachmentBehavior.damping = 0.7f;
				strongSelf.attachmentBehavior.frequency = 1.0f;
				[strongSelf.behavior addChildBehavior:strongSelf.attachmentBehavior];
			}
            if ([strongSelf.viewController respondsToSelector:@selector(viewDidPush)]) {
                [(UIViewController<FCDynamicPaneViewController>*)strongSelf.viewController viewDidPush];
            }
        };
    } else if (state == FCDynamicPaneStateRetracted) {
        self.attachmentBehavior.anchorPoint = CGPointMake(160, [UIScreen mainScreen].bounds.size.height / 2 + TILE_Y);
        self.attachmentBehavior.damping = 0.4f;
        self.attachmentBehavior.frequency = 4.0f;
        self.gravityBehavior.gravityDirection = CGVectorMake(0, 1.5);
        [self.behavior addChildBehavior:self.attachmentBehavior];
        if ([self.viewController respondsToSelector:@selector(viewDidPop)]) {
            [(UIViewController<FCDynamicPaneViewController>*)self.viewController viewDidPop];
        }
    } else if (state == FCDynamicPaneStateActive) {
        self.attachmentBehavior.anchorPoint = CGPointMake(160, [UIScreen mainScreen].bounds.size.height / 2 + TILE_Y);
        self.attachmentBehavior.damping = 0.4f;
        self.attachmentBehavior.frequency = 2.0f;
        self.gravityBehavior.gravityDirection = CGVectorMake(0, -1.5);
        [self.behavior addChildBehavior:self.attachmentBehavior];
        if ([self.viewController respondsToSelector:@selector(viewDidPush)]) {
            [(UIViewController<FCDynamicPaneViewController>*)self.viewController viewDidPush];
        }
    }

    _state = state;
}

- (void)setSwipeEnabled:(BOOL)swipeEnabled
{
    if (_swipeEnabled != swipeEnabled) {
        _swipeEnabled = swipeEnabled;
        if (!swipeEnabled) {
            [_viewController.view removeGestureRecognizer:self.panGestureRecognizer];
        } else {
            [_viewController.view addGestureRecognizer:self.panGestureRecognizer];
        }
    }
}

- (FCDynamicPanesNavigationController*)panesNavigationController
{
    if (!_panesNavigationController) {
        UIViewController* currentParentViewController = self.parentViewController;
        while (currentParentViewController && ![currentParentViewController isKindOfClass:[FCDynamicPanesNavigationController class]]) {
            currentParentViewController = currentParentViewController.parentViewController;
        }
        _panesNavigationController = (FCDynamicPanesNavigationController*)currentParentViewController;
    }
    return _panesNavigationController;
}

@end

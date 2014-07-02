//
//  ContainerViewController.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/26/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "ContainerViewController.h"
#import "TimelineViewController.h"
#import "MentionsViewController.h"
#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "TwitterClient.h"

#define kSlideMargin 55
#define kFrameMargin 0.000020

#pragma mark -
@interface ContainerViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;


- (IBAction)onPan:(UIPanGestureRecognizer *)sender;
- (IBAction)onTap:(UITapGestureRecognizer *)sender;

@end

@implementation ContainerViewController

#pragma mark initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewControllers = [NSMutableArray array];
    }
    return self;
}

#pragma addViewData

- (void)viewDidLoad
{
    //NSLog(@"Container view did load called");
    [super viewDidLoad];
    [self addNotificationObservation];
    [self addViewElements];
}

- (void) addNotificationObservation {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(slideTimeline)
                                                 name:@"Timeline"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(slideMentions)
                                                 name:@"Mentions"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(slideProfile)
                                                 name:@"Profile"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disablePan)
                                                 name:@"Disable Pan"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toggleMenu)
                                                 name:@"Show Menu"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signOut)
                                                 name:@"Sign Off"
                                               object:nil];
}

- (void) addViewElements {
    

    
    // Add sidebar Menu controller
    [self addChildViewController:self.menuViewController];
    self.menuViewController.view.frame = self.menuView.frame;
    [self.menuView addSubview:self.menuViewController.view];
    [self.menuViewController didMoveToParentViewController:self];
    
    // Add the initial ContentController
    [self addChildViewController:self.currentViewController];
    self.currentViewController.view.frame = self.contentView.frame;
    [self.contentView addSubview:self.currentViewController.view];
    [self.currentViewController didMoveToParentViewController:self];
    
    self.tapGesture.enabled = NO;
}

- (void) addContainerViewController:(UIViewController *) viewController {
    
    [self.viewControllers addObject:viewController];
    
}

#pragma display/hide view controllers
- (void) displayViewController: (UIViewController*) currentViewController toFrame:(CGRect) frame
{
    [self addChildViewController:currentViewController];
    currentViewController.view.frame = self.contentView.frame;
    [self.contentView addSubview:currentViewController.view];
    [currentViewController didMoveToParentViewController:self];
}

- (void) hideViewController: (UIViewController*) currentViewController
{
    [currentViewController willMoveToParentViewController:nil];
    [currentViewController.view removeFromSuperview];
    [currentViewController removeFromParentViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    UIView *view = gestureRecognizer.view;
    CGPoint locationInView = [gestureRecognizer locationInView:view];
    CGPoint locationInSuperview = [gestureRecognizer locationInView:view.superview];
    
    view.layer.anchorPoint = CGPointMake(locationInView.x / view.bounds.size.width, locationInView.y / view.bounds.size.height);
    view.center = locationInSuperview;
}

- (IBAction)onPan:(UIPanGestureRecognizer *)panGesture {
    //NSLog(@"Got Pan!");
    
    UIView *view  = panGesture.view;
    
    CGPoint transition = [panGesture locationInView:self.view];
    transition.y = 0;
    
    
    CGPoint velocity = [panGesture velocityInView:self.view];
    
    //NSLog(@"Initial frame x %f  Velocity: %f", view.frame.origin.x, velocity.x);

    if (view.frame.origin.x <= kFrameMargin && velocity.x <= 0) {
        //NSLog(@"frame x %f  Velocity: %f", view.frame.origin.x, velocity.x);
        //view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            //if (velocity.x >= -10) {
            view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            self.tapGesture.enabled = NO;
            //}
        } completion:nil];
        return;
    }

    
    if (panGesture.state == UIGestureRecognizerStateBegan ) {

        if (view.frame.origin.x <= kFrameMargin && velocity.x <= 0) {
            //NSLog(@"frame x %f  Velocity: %f", view.frame.origin.x, velocity.x);
            //view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                //if (velocity.x >= -10) {
                view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
                self.tapGesture.enabled = NO;
                //}
            } completion:nil];
            return;
        }

        [self adjustAnchorPointForGestureRecognizer:panGesture];
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [panGesture translationInView:[view superview]];
        
        // I edited this line so that the image view cannont move vertically
        [view setCenter:CGPointMake([view center].x + translation.x, [view center].y)];
        //[self.contentView setCenter:CGPointMake([view center].x + translation.x, [view center].y)];
        
        [panGesture setTranslation:CGPointZero inView:[view superview]];
        //[panGesture setTranslation:CGPointZero inView:self.contentView];
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint translation = [panGesture translationInView:[view superview]];
        
        // I edited this line so that the image view cannont move vertically
        [view setCenter:CGPointMake([view center].x + translation.x, [view center].y)];
        //[self.contentView setCenter:CGPointMake([view center].x + translation.x, [view center].y)];
        
        [panGesture setTranslation:CGPointZero inView:[view superview]];
        //[panGesture setTranslation:CGPointZero inView:self.contentView];
        
        
        if (velocity.x >= 20) {
            if (view.frame.origin.x >= view.frame.size.width/6) {
                [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    //if (velocity.x >= 20) {
                        //view.center = leftPoint;
                        view.frame = CGRectMake(view.frame.size.width-kSlideMargin, 0, view.frame.size.width, view.frame.size.height);
                        self.tapGesture.enabled = YES;
                        //NSLog(@"content view frame: %f, %f", self.contentView.frame.origin.x, self.contentView.frame.origin.y);
                        //NSLog(@"pan view frame: %f, %f", view.frame.origin.x, view.frame.origin.y);


                    //}
                } completion:nil];
            } else {
                [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    //if (velocity.x >= -10) {
                    view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
                    self.tapGesture.enabled = NO;
                    //}
                } completion:nil];
            }
        } else {
            [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                //if (velocity.x >= -10) {
                view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
                self.tapGesture.enabled = NO;
                //}
            } completion:nil];
        }
    }
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    //NSLog(@"Tapped");
    if (self.contentView.frame.origin.x >= kFrameMargin) {
        [UIView animateWithDuration:1 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:0 animations:^{
            CGRect originalFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.contentView.frame = originalFrame;
            self.tapGesture.enabled = NO;
        } completion:nil];
    }
}

- (void)slideTimeline {
    
    UINavigationController *nvc = (UINavigationController *) self.currentViewController;
    //NSLog(@"current view controller class %@", [nvc.topViewController class]);
    
    //NSLog(@"SlideTimeline %@", nvc.topViewController);
    if ([nvc.topViewController class] == [TimelineViewController class]) {
        //NSLog(@"found timeline controller");
        if (self.contentView.frame.origin.x != 0) {
            [UIView animateWithDuration:1 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:0 animations:^{
                CGRect originalFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                self.contentView.frame = originalFrame;
            } completion:nil];
            self.tapGesture.enabled = NO;
        }
    } else  {
        UIViewController *vc = [self getViewControllerForClass:[TimelineViewController class]];
        if (vc) {
            //NSLog(@"Found view controller for class %@", [vc class]);
            
            [self switchViewController:vc];

        }
        //NSLog(@"Could not find a vc for MentionsViewController class");
    }
}

- (void)slideMentions {
    
    
    UINavigationController *nvc = (UINavigationController *) self.currentViewController;
    //NSLog(@"current view controller class %@", [nvc.topViewController class]);

    //NSLog(@"slideMentions %@", nvc.topViewController);
    if ([nvc.topViewController class] == [MentionsViewController class]) {
        //NSLog(@"found timeline controller");
        if (self.contentView.frame.origin.x != 0) {
            [UIView animateWithDuration:1 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:0 animations:^{
                CGRect originalFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                self.contentView.frame = originalFrame;
            } completion:nil];
            self.tapGesture.enabled = NO;
        }
    } else {
        //NSLog(@"Looking for queued view controllers");
        UIViewController *vc = [self getViewControllerForClass:[MentionsViewController class]];
        if (vc) {
            NSLog(@"Found view controller for class %@", [vc class]);
            
            [self switchViewController:vc];
          }
        //else NSLog(@"Could not find a vc for MentionsViewController class");
    }
}

- (void)slideProfile {
    
    
    UINavigationController *nvc = (UINavigationController *) self.currentViewController;
    //NSLog(@"current view controller class %@", [nvc.topViewController class]);
    
    //NSLog(@"slideProfile %@", nvc.topViewController);
    if ([nvc.topViewController class] == [ProfileViewController class]) {
        //NSLog(@"found timeline controller");
        if (self.contentView.frame.origin.x != 0) {
            [UIView animateWithDuration:1 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:0 animations:^{
                CGRect originalFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                self.contentView.frame = originalFrame;
            } completion:nil];
            self.tapGesture.enabled = NO;
        }
    } else {
        //NSLog(@"Looking for queued view controllers");
        UIViewController *vc = [self getViewControllerForClass:[ProfileViewController class]];
        if (vc) {
            //NSLog(@"Found view controller for class %@", [vc class]);
            
            [self switchViewController:vc];
        }
        //else NSLog(@"Could not find a vc for ProfileViewController class");
    }
}

- (void)toggleMenu {
    self.panGestureRecognizer.enabled = YES;
    
    //NSLog(@"Toggling Menu");
    if (fabs(self.contentView.frame.origin.x) >= kFrameMargin) {
        //NSLog(@"Hiding Menu");
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            //view.center = leftPoint;
            CGRect frame = self.contentView.frame;

            
            self.contentView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            self.tapGesture.enabled = NO;
            //NSLog(@"content view frame: %f, %f", self.contentView.frame.origin.x, self.contentView.frame.origin.y);
            //NSLog(@"pan view frame: %f, %f", self.contentView.frame.origin.x, self.contentView.frame.origin.y);
            
            
        } completion:nil];
    } else {
        //NSLog(@"Displaying Menu");
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            //view.center = leftPoint;
            CGRect frame = self.contentView.frame;
            
            self.contentView.frame = CGRectMake(frame.size.width-kSlideMargin, 0, frame.size.width, frame.size.height);
            self.tapGesture.enabled = YES;
            //NSLog(@"content view frame: %f, %f", self.contentView.frame.origin.x, self.contentView.frame.origin.y);
            //NSLog(@"pan view frame: %f, %f", self.contentView.frame.origin.x, self.contentView.frame.origin.y);
            
            
        } completion:nil];
    }
}

- (void)disablePan {
    self.panGestureRecognizer.enabled = NO;
}

- (void) signOut {
    LoginViewController       *lvc = [[LoginViewController alloc] init];
    
    [[TwitterClient instance] deauthorize];
    [[TwitterClient instance].requestSerializer removeAccessToken];
    
    [self presentViewController:lvc animated:YES completion:nil];
}

- (void) switchViewController:(UIViewController *) vc {
    UINavigationController *nvc = (UINavigationController *) self.currentViewController;
    //NSLog(@"current view controller class %@", [nvc.topViewController class]);
    
    
    [self hideViewController:nvc];
    [nvc addChildViewController:vc];
    self.currentViewController = nvc;
    //NSLog(@"content view frame: %f, %f", self.contentView.frame.origin.x, self.contentView.frame.origin.y);
    [self displayViewController:nvc toFrame:self.contentView.frame];
    CGRect originalFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    nvc.view.frame = originalFrame;
    
    
    [UIView animateWithDuration:1 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:0 animations:^{
        //CGRect originalFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.contentView.frame = originalFrame;
        //nvc.view.frame = originalFrame;
        
    } completion:nil];
    self.tapGesture.enabled = NO;
}

- (UIViewController *) getViewControllerForClass:(Class) className {

    //NSLog(@"looking for a View controller of class %@", className);
    //NSLog(@"viewcontrollers: %d", [self.viewControllers count]);
    for (UIViewController* vc in self.viewControllers) {
        //NSLog(@"vc class %@", [vc class]);
        if ([vc class] == className) {
            return vc;
        }
    }
    return nil;
}

@end

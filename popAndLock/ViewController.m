//
//  ViewController.m
//  popAndLock
//
//  Created by Vensi Developer on 8/17/14.
//  Copyright (c) 2014 EnterWithBoldness. All rights reserved.
//

#define BIG_SIZE  CGSizeMake(320, 320)
#define SMALL_SIZE  CGSizeMake(200, 200)

#import "ViewController.h"

@interface ViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property CGRect initalImagePosition;
@property BOOL tapped;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;

@end

@implementation ViewController
- (IBAction)imageTapped:(UITapGestureRecognizer *)sender
{
    
    NSLog(@"IT just got tapped");
    POPSpringAnimation *scaleUpImageWithSpringAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    if (_tapped){
        scaleUpImageWithSpringAnimation.toValue = [NSValue valueWithCGSize:BIG_SIZE];
        _tapped = YES;
    }else{
        _tapped = NO;
        scaleUpImageWithSpringAnimation.toValue = [NSValue valueWithCGSize:SMALL_SIZE];
    }

    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _tapped = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    _initalImagePosition = self.image.frame;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)panning:(UIPanGestureRecognizer *)sender
{
    
    UIGestureRecognizerState state = [sender state];
    if( state == UIGestureRecognizerStateBegan)
    {
        //don't do much
        
    }else if(state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [sender translationInView:self.view];
        CGPoint centerOfView = self.image.center;
        centerOfView.x += translation.x;
        centerOfView.y += translation.y;
        
        //set the image view under the finger of the user.
        self.image.center = centerOfView;
        
        //reset the center of the view, so that the translation doesn't become cummlitive
        [sender setTranslation:CGPointZero inView:self.view];

    }else if( state == UIGestureRecognizerStateEnded)
    {
        //check if the view is less than 1/4 of the up from the bottom of the screen
        NSLog(@"%f :%f",self.image.frame.origin.y, (self.view.frame.size.height  - (self.view.frame.size.height /4)));
        if ( self.image.frame.origin.y >  (self.view.frame.size.height  - (self.view.frame.size.height /3)))
        {
            //we know that the user intends to move the image off the screen so slide if off
            //get the velocity and use it to send the view on its way
            CGPoint velocity = [sender velocityInView:self.view];
            NSLog(@"velocity: %@", NSStringFromCGPoint(velocity));
            
            POPDecayAnimation *animateOutTheViewWithDecay = [POPDecayAnimation animationWithPropertyNamed:kPOPViewFrame];
            animateOutTheViewWithDecay.deceleration = 0.4;
            animateOutTheViewWithDecay.velocity = [NSValue valueWithCGPoint:velocity];
            [self.image pop_addAnimation:animateOutTheViewWithDecay forKey:@"moveOut"];
            

        }else
        {
            //the user wants the image to stay on the screen, so we snap it back into it's inital position
            POPSpringAnimation *animatePositionWithSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
            animatePositionWithSpring.toValue = [NSValue valueWithCGRect:_initalImagePosition];
            animatePositionWithSpring.springBounciness = 10;
            animatePositionWithSpring.springSpeed = 2;

            [self.image pop_addAnimation:animatePositionWithSpring forKey:@"snapToPlace"];
            NSLog(@"shit is supposed to snap back");
            
            
        }
        
    }
    
}


#pragma mark - gesture recognizer delegates
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{

    if(gestureRecognizer == _tapGesture)
    {
        NSLog(@"Tap gesture");
        return YES;
    }else
    {
        NSLog(@"Pan gesture");
        return NO;
    }
    
    
}


@end

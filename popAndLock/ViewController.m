//
//  ViewController.m
//  popAndLock
//
//  Created by Vensi Developer on 8/17/14.
//  Copyright (c) 2014 EnterWithBoldness. All rights reserved.
//

#define BIG_SIZE  CGSizeMake(320, 320)
#define SMALL_SIZE  CGSizeMake(200, 200)

#define MAX_ROTATION_ANGLE 45.0f


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
    //remove the animations so as to not have any gittering effect when we pan and move the image.
    [self.image pop_removeAllAnimations ];
    
    
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
        
        //adding a little rotation transform as the view moves through the screen
        
        CGFloat angle =  [self angleGivenPoint:self.image.frame.origin];
//        NSLog(@"Angle rotated: %f", angle);
        CGAffineTransform transform =  CGAffineTransformRotate(self.image.transform, angle);
        self.image.transform = transform;

        //reset the center of the view, so that the translation doesn't become cummlitive
        [sender setTranslation:CGPointZero inView:self.view];

    }else if( state == UIGestureRecognizerStateEnded)
    {
        //check if the view is less than 1/4 of the up from the bottom of the screen
//        NSLog(@"%f :%f",self.image.frame.origin.y, (self.view.frame.size.height  - (self.view.frame.size.height /4)));
        CGPoint translation = [sender translationInView:self.view];
        CGPoint centerOfView = self.image.center;
        centerOfView.x += translation.x;
        centerOfView.y += translation.y;
        
        //set the rotation to normal
        

//        NSLog(@"%@",NSStringFromCGPoint(self.image.frame.origin));
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
            

        }else if( self.image.frame.origin.x < 0)
        {
            //move the image to the left
            CGPoint velocity = [sender velocityInView:self.view];
//            NSLog(@"velocity: %@", NSStringFromCGPoint(velocity));
            
            POPDecayAnimation *animateOutTheViewWithDecay = [POPDecayAnimation animationWithPropertyNamed:kPOPViewFrame];
            animateOutTheViewWithDecay.deceleration = 0.4;
            animateOutTheViewWithDecay.velocity = [NSValue valueWithCGPoint:velocity];
            [self.image pop_addAnimation:animateOutTheViewWithDecay forKey:@"moveOut"];
            
            
            
        }else if(self.image.frame.origin.x > (self.view.frame.size.width ) )
        {
            //move the image to the right
            CGPoint velocity = [sender velocityInView:self.view];
//            NSLog(@"velocity: %@", NSStringFromCGPoint(velocity));
            
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
//            NSLog(@"shit is supposed to snap back");
            
            
        }
        
    }
    
}



#pragma mark - rotation angle calculator
/**
 *  Given the views origin it returns how much we should rotate it
 *
 *  @param viewOrigin the views origin (in the super view's frame
 *
 *  @return the rotation angle in radians
 */
-(CGFloat)angleGivenPoint:(CGPoint )viewOrigin
{
    CGFloat xCord = viewOrigin.x;
    CGFloat screenWidth = self.view.frame.size.width ;
    CGFloat halfOfScreenWidth = screenWidth /2 ;
    CGFloat rotationFactor =  (xCord - halfOfScreenWidth) / halfOfScreenWidth;
    NSLog(@"Rotation Factor %f",rotationFactor);
    return ((MAX_ROTATION_ANGLE)/ 360.0f) * 2 * M_PI  * rotationFactor ;

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

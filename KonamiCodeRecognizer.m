//
//  KonamiCodeRecognizer.m
//  Kids
//
//  Created by Caio Coan on 6/2/15.
//  Copyright (c) 2015 Encripta. All rights reserved.
//

#import "KonamiCodeRecognizer.h"

#define REQUIRED_MOVES 2
#define MOVE_AMT 25

@implementation KonamiCodeRecognizer
@synthesize count, startPoint, lastDirection;

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    NSLog(@"initGesture");
    if (self == [super initWithTarget:target action:action])
    {
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Began");
    UITouch *touch = [touches anyObject];
    self.startPoint = [touch locationInView:self.view];
    //
    //if ([touch locationInView:self.view].x > CGRectGetMidX(self.view.bounds)) self.state = UIGestureRecognizerStateFailed;
    //else if ([touch locationInView:self.view].y > CGRectGetMidY(self.view.bounds)) self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Moved");
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    CGFloat moveAmt = touchPoint.x - startPoint.x;
    Direction moveDirection;
    if (moveAmt < 0)
    {
        moveDirection = DirectionLeft;
    }else{
        moveDirection = DirectionRight;
    }
    if (ABS(moveAmt) < MOVE_AMT)
        return;
    
    if (lastDirection == DirectionUnknown || (lastDirection == DirectionLeft && moveDirection == DirectionRight) || (lastDirection == DirectionRight && moveDirection == DirectionLeft))
    {
        count++;
        startPoint = touchPoint;
        lastDirection = moveDirection;
        
        if (self.state == UIGestureRecognizerStatePossible && count > REQUIRED_MOVES)
        {
            [self setState:UIGestureRecognizerStateEnded];
        }
    }
   // if ([touch locationInView:self.view].y > CGRectGetMidY(self.view.bounds)) self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Ended");
    [self reset];
    //UITouch *touch = [touches anyObject];
    //if ([touch locationInView:self.view].x < CGRectGetMidX(self.view.bounds)) self.state = UIGestureRecognizerStateFailed;
    //else if ([touch locationInView:self.view].y > CGRectGetMidY(self.view.bounds)) self.state = UIGestureRecognizerStateFailed;
    //else {
    //    self.state = UIGestureRecognizerStateRecognized;
    //}
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Cancelled");
    [self reset];
    //    self.state = UIGestureRecognizerStateCancelled;
}

-(void)reset
{
    count = 0;
    startPoint = CGPointZero;
    lastDirection = DirectionUnknown;
    if (self.state == UIGestureRecognizerStatePossible)
    {
        [self setState:UIGestureRecognizerStateFailed];
    }
}
@end
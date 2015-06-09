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
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Ended");
    [self reset];

}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self reset];
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
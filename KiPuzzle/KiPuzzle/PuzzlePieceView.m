//
//  PuzzlePieceView.m
//  JigsawGame
//
//  Created by Caio Coan on 2/24/15.
//  Copyright (c) 2015 Guntis Treulands. All rights reserved.
//

#import "PuzzlePieceView.h"

@implementation PuzzlePieceView

@synthesize delegate;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    [delegate beginTouchOn:self Touch: touch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    [delegate endTouchOn:self Touch:touch];
}

@end
//
//  PuzzlePieceView.h
//  JigsawGame
//
//  Created by Caio Coan on 2/24/15.
//  Copyright (c) 2015 Caio Coan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PuzzlePieceView;
@protocol PuzzlePieceViewDelegate <NSObject>
@required
- (void)beginTouchOn:(PuzzlePieceView *)piece Touch:(UITouch*)touch;
- (void)endTouchOn:(PuzzlePieceView*)piece Touch:(UITouch*)touch;
@end

@interface PuzzlePieceView : UIImageView <UIGestureRecognizerDelegate>
@property BOOL moveable;
@property CGRect originalPosition;
@property (weak)id <PuzzlePieceViewDelegate> delegate;

@end

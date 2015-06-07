//
//  PuzzleManager.h
//  JigsawGame
//
//  Created by Caio Coan on 2/24/15.
//  Copyright (c) 2015 aio Coan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PuzzleManagerDelegate <NSObject>

@required
- (NSDictionary*) numberOfPiecesForPuzzle;
- (NSArray*) imagesForPuzzle;
- (BOOL) showHintImage;
@end

@interface PuzzleManager : NSObject

@property (weak)id <PuzzleManagerDelegate> delegate;
@property (strong)UIViewController *parentVC;


-(id)initWithParentVC:(UIViewController*)parentVC;

-(void)prepareForStart;
-(void)start;

@end
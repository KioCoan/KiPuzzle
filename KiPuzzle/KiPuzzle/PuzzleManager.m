//
//  PuzzleManager.m
//  JigsawGame
//
//  Created by Caio Coan on 2/24/15.
//  Copyright (c) 2015 Caio Coan. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

#import "SystemUtility.h"

#import "PuzzleManager.h"
#import "PuzzlePieceView.h"
#import "JigsawVC.h"

@interface PuzzleManager() <UIGestureRecognizerDelegate, PuzzlePieceViewDelegate> {
    SystemSoundID pieceSound;
    SystemSoundID winSound;
    
    UIImageView* bg;
    UIImageView* loadingImage;
    
    NSInteger remainingPieces;
    
    NSInteger cubeHeightValue;
    NSInteger cubeWidthValue;
    NSInteger pieceHCount;
    NSInteger pieceVCount;
    NSInteger deepnessH;
    NSInteger deepnessV;
    NSInteger touchedImgViewTag;
    
    CGFloat lastScale;
    CGFloat lastRotation;
    CGFloat firstX;
    CGFloat firstY;
    
    NSMutableArray* piecesTypeValue;
    NSMutableArray* piecesRotationValues;
    NSMutableArray* piecesCoordinateRect;
    NSMutableArray* piecesBezierPaths;
    NSMutableArray* piecesBezierPathsWithouHoles;
    NSMutableArray* allPiecesArray;
    
    UIImage* originalImage;
    UIView* puzzleBoard;
}
@end

@implementation PuzzleManager

@synthesize delegate;

- (id)initWithParentVC:(UIViewController *)parentVC{
    self = [super init];
    _parentVC = parentVC;
    return self;
}

- (void)prepareForStart
{
    pieceHCount = [[delegate numberOfPiecesForPuzzle][@"H"] integerValue];
    pieceVCount = [[delegate numberOfPiecesForPuzzle][@"V"] integerValue];
    NSArray* images = [delegate imagesForPuzzle];
    int selectedPuzzle = arc4random_uniform((unsigned int)images.count);
    originalImage = [images objectAtIndex:selectedPuzzle];
    cubeHeightValue = originalImage.size.height / pieceVCount;
    cubeWidthValue = originalImage.size.width / pieceHCount;
    deepnessH = -(cubeHeightValue / 4);
    deepnessV = -(cubeWidthValue / 4);
    remainingPieces = pieceHCount * pieceVCount;
    puzzleBoard = [[UIView alloc]initWithFrame:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    bg = [[UIImageView alloc]initWithImage:originalImage];
    [puzzleBoard addSubview:bg];
    loadingImage = [[UIImageView alloc] initWithImage:originalImage];
    [_parentVC.view addSubview:loadingImage];
    if ([delegate showHintImage])
        bg.alpha = 0.3;
    else
        bg.alpha = 0;
    [_parentVC.view addSubview:puzzleBoard];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        puzzleBoard.center = CGPointMake(CGRectGetMidX(puzzleBoard.superview.frame), CGRectGetMidY(puzzleBoard.superview.frame));
        loadingImage.center = puzzleBoard.center;
    }
}

- (void)start
{
    [self setUpPiecesCoordinatesTypesAndRotationValues];
    [self setUpPiecesBezierPaths];
    [self setupPuzzlePiecesImages];
    [self shufflePieces];
    [(JigsawVC*)_parentVC fixCloseButton];
}

- (void)checkGameState
{
    [(JigsawVC*)_parentVC fixCloseButton];
    if(remainingPieces == 0){
        [self finishGame];
    }
}

- (void)finishGame
{
    NSString* soundName = [[NSBundle mainBundle]pathForResource:@"successPurchase" ofType:@"caf"];
    NSURL* soundUrl = [NSURL URLWithString:soundName];
    AudioServicesCreateSystemSoundID(((__bridge CFURLRef)soundUrl), &winSound);
    AudioServicesPlaySystemSound(winSound);
    UIView* whiteView = [[UIView alloc]initWithFrame:puzzleBoard.frame];
    whiteView.alpha = 0;
    whiteView.backgroundColor = [UIColor whiteColor];
    [puzzleBoard addSubview:whiteView];
    [puzzleBoard bringSubviewToFront:whiteView];
    [UIView animateWithDuration:0.2 animations:^(void){
        whiteView.alpha = 1;
    }completion:^(BOOL finished){
        for (PuzzlePieceView* piece in allPiecesArray){
            [piece removeFromSuperview];
        }
        allPiecesArray = nil;
        bg.alpha = 1;
        [UIView animateWithDuration:0.2 animations:^(void){
            whiteView.alpha = 0;
        }completion:^(BOOL finished){
            JigsawVC* jigVC = (JigsawVC*)_parentVC;
            jigVC.btnClose.hidden = YES;
            [whiteView removeFromSuperview];
            [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(closeGame) userInfo:nil repeats:NO];
        }];
    }];
}

-(void)winTap:(id)sender
{
    [self closeGame];
}

-(void)closeGame
{
    [_parentVC dismissViewControllerAnimated:YES completion:nil];
}

-(void)setUpPiecesCoordinatesTypesAndRotationValues
{
    piecesTypeValue = [NSMutableArray new];
    piecesCoordinateRect = [NSMutableArray new];
    piecesRotationValues = [NSMutableArray new];
    NSInteger mSide1 = 0, mSide2 = 0, mSide3 = 0, mSide4 = 0, mCounter = 0, mCubeWidth = 0, mCubeHeight = 0, mXPoint = 0, mYPoint = 0;
    for(NSInteger i = 0; i < pieceVCount; i++){
        for (NSInteger j = 0; j < pieceHCount; j++) {
            if(j != 0)
            {
                mSide1 = ([[[piecesTypeValue objectAtIndex:mCounter-1] objectAtIndex:2] intValue] == 1)?-1:1;
            }
            if(i != 0)
            {
                mSide4 = ([[[piecesTypeValue objectAtIndex:mCounter-pieceHCount] objectAtIndex:1] intValue] == 1)?-1:1;
            }
            mSide2 = ((arc4random() % 2) == 1)?1:-1;
            mSide3 = ((arc4random() % 2) == 1)?1:-1;
            if(i == 0)
                mSide4 = 0;
            if(j == 0)
                mSide1 = 0;
            if(i == pieceVCount-1)
                mSide2 = 0;
            if(j == pieceHCount-1)
                mSide3 = 0;
            //Cube height and Width
            mCubeHeight = cubeHeightValue;
            mCubeWidth = cubeWidthValue;
            if (mSide1 == 1)
                mCubeWidth -= deepnessV;
            if (mSide3 == 1)
                mCubeWidth -= deepnessV;
            if (mSide2 == 1)
                mCubeHeight -= deepnessH;
            if (mSide4 == 1)
                mCubeHeight -= deepnessH;
            [piecesTypeValue addObject:[NSArray arrayWithObjects:
                                         [NSString stringWithFormat:@"%ld",mSide1],
                                         [NSString stringWithFormat:@"%ld",mSide2],
                                         [NSString stringWithFormat:@"%ld",mSide3],
                                         [NSString stringWithFormat:@"%ld",mSide4],
                                         nil]];
            mXPoint = MAX(mCubeWidth, MIN(arc4random() % MAX(1,(int)(_parentVC.view.frame.size.width - mCubeWidth*2)) + mCubeWidth, _parentVC.view.frame.size.width - mCubeWidth*2));
            mYPoint = MAX(mCubeHeight, MIN(arc4random() % MAX(1,(int)(_parentVC.view.frame.size.height - mCubeHeight*2)) + mCubeHeight, _parentVC.view.frame.size.height - mCubeHeight*2));
            [piecesCoordinateRect addObject:[NSArray arrayWithObjects:
                                              [NSValue valueWithCGRect:CGRectMake(j*cubeWidthValue,i*cubeHeightValue,mCubeWidth,mCubeHeight)],
                                              [NSValue valueWithCGRect:CGRectMake(j*cubeWidthValue-(mSide1==1?-deepnessV:0), i*cubeHeightValue-(mSide4==1?-deepnessH:0), mCubeWidth, mCubeHeight)],
                                              nil]];
            //Rotation
            [piecesRotationValues addObject:[NSNumber numberWithFloat:0]];
            mCounter++;
        }
    }
}

-(void)setUpPiecesBezierPaths
{
    piecesBezierPaths = [NSMutableArray new];
    piecesBezierPathsWithouHoles = [NSMutableArray new];
    float mYSideStartPos = 0, mXSideStartPos = 0, mCustomDeepness = 0, mCurveHalfVLength = cubeWidthValue / 10, mCurveHalfHLength = cubeHeightValue / 10, mCurveStartXPos = cubeWidthValue / 2 - mCurveHalfVLength, mCurveStartYPos = cubeHeightValue / 2 - mCurveHalfHLength, mTotalHeight = 0, mTotalWidth = 0;
    for (int i = 0; i < [piecesTypeValue count]; i++){
        mXSideStartPos = ([[[piecesTypeValue objectAtIndex:i] objectAtIndex:0] intValue] == 1)?-deepnessV:0;
        mYSideStartPos = ([[[piecesTypeValue objectAtIndex:i] objectAtIndex:3] intValue] == 1)?-deepnessH:0;
        mTotalHeight = mYSideStartPos + mCurveStartYPos*2 + mCurveHalfHLength*2;
        mTotalWidth = mXSideStartPos + mCurveStartXPos*2 + mCurveHalfVLength*2;
        //BezierPath begins
        UIBezierPath* mPieceBezier = [UIBezierPath bezierPath];
        [mPieceBezier moveToPoint:CGPointMake(mXSideStartPos, mYSideStartPos)];
        UIBezierPath* mTouchPieceBezier = [UIBezierPath bezierPath];
        [mTouchPieceBezier moveToPoint:CGPointMake(mXSideStartPos, mYSideStartPos)];
        //=================== LEFT SIDE ===================
        [mPieceBezier addLineToPoint:CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos)];
        if(![[[piecesTypeValue objectAtIndex:i] objectAtIndex:0] isEqualToString:@"0"]){
            mCustomDeepness = deepnessV * [[[piecesTypeValue objectAtIndex:i] objectAtIndex:0] intValue];
            [mPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos+mCurveHalfHLength) controlPoint1: CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos) controlPoint2: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength - mCurveStartYPos)];
            [mPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength*2) controlPoint1: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength + mCurveStartYPos) controlPoint2: CGPointMake(mXSideStartPos, mYSideStartPos+mCurveStartYPos + mCurveHalfHLength*2)];
        }
        [mPieceBezier addLineToPoint: CGPointMake(mXSideStartPos, mTotalHeight)];
        [mTouchPieceBezier addLineToPoint:CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos)];
        if ([[[piecesTypeValue objectAtIndex:i] objectAtIndex:0] isEqualToString:@"1"]) {
            mCustomDeepness = deepnessV;
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos+mCurveHalfHLength) controlPoint1: CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos) controlPoint2: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength - mCurveStartYPos)];
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength*2) controlPoint1: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength + mCurveStartYPos) controlPoint2: CGPointMake(mXSideStartPos, mYSideStartPos+mCurveStartYPos + mCurveHalfHLength*2)];
        }
        [mTouchPieceBezier addLineToPoint: CGPointMake(mXSideStartPos, mTotalHeight)];
        //=================== BOTTOM ===================
        [mPieceBezier addLineToPoint: CGPointMake(mXSideStartPos+ mCurveStartXPos, mTotalHeight)];
        if(![[[piecesTypeValue objectAtIndex:i] objectAtIndex:1] isEqualToString:@"0"])
        {
            mCustomDeepness = deepnessH * [[[piecesTypeValue objectAtIndex:i] objectAtIndex:1] intValue];
            [mPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength, mTotalHeight - mCustomDeepness) controlPoint1: CGPointMake(mXSideStartPos + mCurveStartXPos, mTotalHeight) controlPoint2: CGPointMake(mXSideStartPos + mCurveHalfVLength, mTotalHeight - mCustomDeepness)];
            [mPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength+mCurveHalfVLength, mTotalHeight) controlPoint1: CGPointMake(mTotalWidth - mCurveHalfVLength, mTotalHeight - mCustomDeepness) controlPoint2: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength + mCurveHalfVLength, mTotalHeight)];
        }
        [mPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mTotalHeight)];
        [mTouchPieceBezier addLineToPoint: CGPointMake(mXSideStartPos+ mCurveStartXPos, mTotalHeight)];
        if([[[piecesTypeValue objectAtIndex:i] objectAtIndex:1] isEqualToString:@"1"])
        {
            mCustomDeepness = deepnessH;
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength, mTotalHeight - mCustomDeepness) controlPoint1: CGPointMake(mXSideStartPos + mCurveStartXPos, mTotalHeight) controlPoint2: CGPointMake(mXSideStartPos + mCurveHalfVLength, mTotalHeight - mCustomDeepness)];
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength+mCurveHalfVLength, mTotalHeight) controlPoint1: CGPointMake(mTotalWidth - mCurveHalfVLength, mTotalHeight - mCustomDeepness) controlPoint2: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength + mCurveHalfVLength, mTotalHeight)];
        }
        [mTouchPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mTotalHeight)];
        //=================== RIGHT SIDE ===================
        [mPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mTotalHeight - mCurveStartYPos)];
        if(![[[piecesTypeValue objectAtIndex:i] objectAtIndex:2] isEqualToString:@"0"])
        {
            mCustomDeepness = deepnessV * [[[piecesTypeValue objectAtIndex:i] objectAtIndex:2] intValue];
            [mPieceBezier addCurveToPoint: CGPointMake(mTotalWidth - mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength) controlPoint1: CGPointMake(mTotalWidth, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength * 2) controlPoint2: CGPointMake(mTotalWidth - mCustomDeepness, mTotalHeight - mCurveHalfHLength)];
            [mPieceBezier addCurveToPoint: CGPointMake(mTotalWidth, mYSideStartPos + mCurveStartYPos) controlPoint1: CGPointMake(mTotalWidth - mCustomDeepness, mYSideStartPos + mCurveHalfHLength) controlPoint2: CGPointMake(mTotalWidth, mCurveStartYPos + mYSideStartPos)];
        }
        [mPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mYSideStartPos)];
        [mTouchPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mTotalHeight - mCurveStartYPos)];
        if([[[piecesTypeValue objectAtIndex:i] objectAtIndex:2] isEqualToString:@"1"])
        {
            mCustomDeepness = deepnessV;
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mTotalWidth - mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength) controlPoint1: CGPointMake(mTotalWidth, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength * 2) controlPoint2: CGPointMake(mTotalWidth - mCustomDeepness, mTotalHeight - mCurveHalfHLength)];
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mTotalWidth, mYSideStartPos + mCurveStartYPos) controlPoint1: CGPointMake(mTotalWidth - mCustomDeepness, mYSideStartPos + mCurveHalfHLength) controlPoint2: CGPointMake(mTotalWidth, mCurveStartYPos + mYSideStartPos)];
        }
        [mTouchPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mYSideStartPos)];
        //================== TOP ===================
        [mPieceBezier addLineToPoint: CGPointMake(mTotalWidth - mCurveStartXPos, mYSideStartPos)];
        if(![[[piecesTypeValue objectAtIndex:i] objectAtIndex:3] isEqualToString:@"0"])
        {
            mCustomDeepness = deepnessH * [[[piecesTypeValue objectAtIndex:i] objectAtIndex:3] intValue];
            [mPieceBezier addCurveToPoint: CGPointMake(mTotalWidth - mCurveStartXPos - mCurveHalfVLength, mYSideStartPos + mCustomDeepness) controlPoint1: CGPointMake(mTotalWidth - mCurveStartXPos, mYSideStartPos) controlPoint2: CGPointMake(mTotalWidth - mCurveHalfVLength, mYSideStartPos + mCustomDeepness)];
            [mPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos, mYSideStartPos) controlPoint1: CGPointMake(mXSideStartPos + mCurveHalfVLength, mYSideStartPos + mCustomDeepness) controlPoint2: CGPointMake(mXSideStartPos + mCurveStartXPos, mYSideStartPos)];
        }
        [mPieceBezier addLineToPoint: CGPointMake(mXSideStartPos, mYSideStartPos)];
        [mTouchPieceBezier addLineToPoint: CGPointMake(mTotalWidth - mCurveStartXPos, mYSideStartPos)];
        if([[[piecesTypeValue objectAtIndex:i] objectAtIndex:3] isEqualToString:@"1"])
        {
            mCustomDeepness = deepnessH;
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mTotalWidth - mCurveStartXPos - mCurveHalfVLength, mYSideStartPos + mCustomDeepness) controlPoint1: CGPointMake(mTotalWidth - mCurveStartXPos, mYSideStartPos) controlPoint2: CGPointMake(mTotalWidth - mCurveHalfVLength, mYSideStartPos + mCustomDeepness)];
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos, mYSideStartPos) controlPoint1: CGPointMake(mXSideStartPos + mCurveHalfVLength, mYSideStartPos + mCustomDeepness) controlPoint2: CGPointMake(mXSideStartPos + mCurveStartXPos, mYSideStartPos)];
        }
        [mTouchPieceBezier addLineToPoint: CGPointMake(mXSideStartPos, mYSideStartPos)];
        //============ END ============
        [piecesBezierPaths addObject:mPieceBezier];
        [piecesBezierPathsWithouHoles addObject:mTouchPieceBezier];
    }
}

-(void)setupPuzzlePiecesImages
{
    allPiecesArray = [NSMutableArray new];
    float mXAddableVal = 0, mYAddableVal = 0;
    for (int i = 0; i < [piecesBezierPaths count]; i++){
        CGRect mCropFrame = [[[piecesCoordinateRect objectAtIndex:i] objectAtIndex:0] CGRectValue];
        CGRect mImageFrame = [[[piecesCoordinateRect objectAtIndex:i] objectAtIndex:1] CGRectValue];
        //======= PUZZLE PIECE =========
        PuzzlePieceView *mPiece = [PuzzlePieceView new];
        mPiece.delegate = self;
        [mPiece setFrame:mImageFrame];
        [mPiece setTag:i+100];
        [mPiece setUserInteractionEnabled:YES];
        [mPiece setContentMode:UIViewContentModeTopLeft];
        [mPiece setOriginalPosition:mPiece.frame];
        [mPiece setMoveable:YES];
        //======= ADDABLE VALUE ========
        mXAddableVal = ([[[piecesTypeValue objectAtIndex:i] objectAtIndex:0] intValue] == 1)?deepnessV:0;
        mYAddableVal = ([[[piecesTypeValue objectAtIndex:i] objectAtIndex:3] intValue] == 1)?deepnessH:0;
        mCropFrame.origin.x += mXAddableVal;
        mCropFrame.origin.y += mYAddableVal;
        //======= CROP, CLIP AND ADD TO VIEW ========
        [mPiece setImage:[self cropImage:originalImage withRect:mCropFrame]];
        [self setClippingPath:[piecesBezierPaths objectAtIndex:i]:mPiece];
        [puzzleBoard addSubview:mPiece];
        [mPiece setTransform:CGAffineTransformMakeRotation([[piecesRotationValues objectAtIndex:i] floatValue])];
        //======= BORDER LINE ========
        CAShapeLayer *mBorderPathLayer = [CAShapeLayer layer];
        [mBorderPathLayer setPath:[[piecesBezierPaths objectAtIndex:i] CGPath]];
        [mBorderPathLayer setFillColor:[UIColor clearColor].CGColor];
        [mBorderPathLayer setStrokeColor:[UIColor blackColor].CGColor];
        [mBorderPathLayer setLineWidth:2];
        [mBorderPathLayer setFrame:CGRectZero];
        [[mPiece layer] addSublayer:mBorderPathLayer];
         //======= BORDER LINE FOR TOUCH RECOGNITION =========
        CAShapeLayer *mSecretBorder = [CAShapeLayer layer];
        [mSecretBorder setPath:[[piecesBezierPaths objectAtIndex:i] CGPath]];
        [mSecretBorder setFillColor:[UIColor clearColor].CGColor];
        [mSecretBorder setStrokeColor:[UIColor blackColor].CGColor];
        [mSecretBorder setLineWidth:0];
        [mSecretBorder setFrame:CGRectZero];
        [[mPiece layer] addSublayer:mSecretBorder];
        //======= GESTURES =========
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelegate:self];
        [mPiece addGestureRecognizer:panRecognizer];
        [allPiecesArray addObject:mPiece];
    }
}

-(UIImage *) cropImage:(UIImage*)originalImg withRect:(CGRect)rect
{
    return [UIImage imageWithCGImage:CGImageCreateWithImageInRect([originalImg CGImage], rect)];
}

- (void) setClippingPath:(UIBezierPath *)clippingPath : (UIImageView *)imgView;
{
    if (![[imgView layer] mask])
    {

        [[imgView layer] setMask:[CAShapeLayer layer]];
    }
    [(CAShapeLayer*) [[imgView layer] mask] setPath:[clippingPath CGPath]];
}

- (void)shufflePieces
{
    for (PuzzlePieceView* piece in allPiecesArray)
    {
        float maxX = puzzleBoard.frame.size.width - (cubeWidthValue / 2);
        float minX = cubeWidthValue;
        float maxY = puzzleBoard.frame.size.height - (cubeHeightValue / 2);
        float minY = cubeHeightValue;
        CGPoint location = CGPointMake(arc4random_uniform((maxX - minX + 1)+minX), (arc4random_uniform(maxY - minY + 1)+minY));
        piece.center = location;
    }
    [_parentVC.view bringSubviewToFront:loadingImage];
    [self showPuzzle];
}

- (void)showPuzzle
{
    [UIView animateWithDuration:0.8 animations:^{
        loadingImage.alpha = 0;
    }completion:^(BOOL finished){
       [loadingImage removeFromSuperview];
    }];
}
 
//PuzzlePieceViewDelegate

- (void)beginTouchOn:(PuzzlePieceView *)piece Touch:(UITouch *)touch
{
    touchedImgViewTag = 0;
    CGPoint location = [touch locationInView:puzzleBoard];
    location = [touch locationInView:piece];
    if (CGPathContainsPoint([(CAShapeLayer*) [[[piece layer] sublayers] objectAtIndex:1] path], nil, location, NO))
    {
        if (!piece.moveable) {
            return;
        }
        touchedImgViewTag = piece.tag;
        [puzzleBoard bringSubviewToFront:piece];
        firstX = piece.center.x;
        firstY = piece.center.y;
        NSString* soundPath = [[NSBundle mainBundle]pathForResource:@"pieceGrab" ofType:@"caf"];
        NSURL* soundUrl = [NSURL URLWithString:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl, &pieceSound);
        AudioServicesPlaySystemSound(pieceSound);
        return;
    }
}

- (void)endTouchOn:(PuzzlePieceView *)piece Touch:(UITouch *)touch
{
    if (touchedImgViewTag == 0) {
        return;
    }
    CGPoint location = [touch locationInView:puzzleBoard];
    if (!piece || ![piece isKindOfClass:[PuzzlePieceView class]]) {
        CGFloat mRotation = [[piecesRotationValues objectAtIndex:piece.tag - 100] floatValue];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        if (mRotation >= 0 && mRotation < M_PI/2) {
            [piece setTransform:CGAffineTransformMakeRotation(M_PI/2)];
            mRotation = M_PI/2;
        }
        else if(mRotation >= M_PI/2 && mRotation < M_PI)
        {
            [piece setTransform:CGAffineTransformMakeRotation(M_PI)];
            mRotation = M_PI;
        }
        else if(mRotation >= M_PI && mRotation < M_PI + M_PI/2)
        {
            [piece setTransform:CGAffineTransformMakeRotation(M_PI + M_PI/2)];
            mRotation = M_PI + M_PI/2;
        }
        else
        {
            [piece setTransform:CGAffineTransformMakeRotation(M_PI*2)];
            mRotation = 0;
        }
        if (CGRectContainsPoint(piece.originalPosition, location)) {
            piece.frame = piece.originalPosition;
            piece.moveable = NO;
        }
        [UIView commitAnimations];
        [piecesRotationValues replaceObjectAtIndex:piece.tag-100 withObject:[NSNumber numberWithFloat:mRotation]];
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    if (CGRectContainsPoint(piece.originalPosition, location)) {
        piece.frame = piece.originalPosition;
        piece.moveable = NO;
        remainingPieces -= 1;
        NSString* soundPath = [[NSBundle mainBundle]pathForResource:@"pieceRelease" ofType:@"caf"];
        NSURL* soundUrl = [NSURL URLWithString:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl, &pieceSound);
        AudioServicesPlaySystemSound(pieceSound);
    }
    [UIView commitAnimations];
    for (PuzzlePieceView* piece in allPiecesArray) {
        if (piece.moveable) {
            [puzzleBoard bringSubviewToFront:piece];
        }
    }
    [self checkGameState];
}

- (void)move:(id)sender
{
    CGPoint tranlatedPoint = [(UIPanGestureRecognizer*)sender translationInView:puzzleBoard];
    if (touchedImgViewTag == 0 || touchedImgViewTag == 99) {
        return;
    }
    PuzzlePieceView *piece = (PuzzlePieceView*)([puzzleBoard viewWithTag:touchedImgViewTag]);
    tranlatedPoint = CGPointMake(firstX+tranlatedPoint.x, firstY+tranlatedPoint.y);
    [piece setCenter:tranlatedPoint];
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if (CGRectContainsPoint(piece.originalPosition, tranlatedPoint)) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.25];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            piece.frame = piece.originalPosition;
            piece.moveable = NO;
            remainingPieces -= 1;
            NSString* soundPath = [[NSBundle mainBundle]pathForResource:@"pieceRelease" ofType:@"caf"];
            NSURL* soundUrl = [NSURL URLWithString:soundPath];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl, &pieceSound);
            AudioServicesPlaySystemSound(pieceSound);
            for (PuzzlePieceView* piece in allPiecesArray) {
                if (piece.moveable) {
                    [puzzleBoard bringSubviewToFront:piece];
                }
            }
            [UIView commitAnimations];
            [self checkGameState];
        }
    }
}

@end

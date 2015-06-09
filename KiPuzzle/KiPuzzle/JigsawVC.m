//
//  JigsawVC.m
//  Kids
//
//  Created by Caio Coan on 3/2/15.
//  Copyright (c) 2015 Encripta. All rights reserved.
//

#import "JigsawVC.h"

#import "PuzzleManager.h"

@interface JigsawVC () <PuzzleManagerDelegate>{
    PuzzleManager* puzzleManager;
}

- (IBAction)closeGame:(id)sender;

@end

@implementation JigsawVC

@synthesize mode, btnClose, currentImage;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    btnClose.layer.borderColor = [UIColor blackColor].CGColor;
    btnClose.layer.borderWidth = 1.0f;
    btnClose.layer.cornerRadius = btnClose.frame.size.height / 2;
    btnClose.layer.masksToBounds = YES;
    puzzleManager = [[PuzzleManager alloc]initWithParentVC:self];
    puzzleManager.delegate = self;
    UIImage* puzzleImage = currentImage[@"Image"];
    [puzzleManager prepareForStart:puzzleImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [puzzleManager start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    puzzleManager.delegate = nil;
    puzzleManager = nil;
}

- (void)fixCloseButton{
    [self.view bringSubviewToFront:btnClose];
}

- (IBAction)closeGame:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - PuzzleManagerDelegate

- (NSDictionary *)numberOfPiecesForPuzzle
{
    return @{@"H":self.numberHorizontal,@"V":self.numberVertical};
}

- (BOOL)showHintImage
{
    if (mode == jigsawKidMode)
        return YES;
    return NO;
}

@end
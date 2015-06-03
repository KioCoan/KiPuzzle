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
@synthesize mode;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _btnClose.layer.borderColor = [UIColor blackColor].CGColor;
    _btnClose.layer.borderWidth = 1.0f;
    _btnClose.layer.cornerRadius = _btnClose.frame.size.height / 2;
    _btnClose.layer.masksToBounds = YES;
    puzzleManager = [[PuzzleManager alloc]initWithParentVC:self];
    puzzleManager.delegate = self;
    [puzzleManager prepareForStart];
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

-(void)fixCloseButton{
    [self.view bringSubviewToFront:_btnClose];
}

- (IBAction)closeGame:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//PuzzleManagerDelegate

- (NSArray *)imagesForPuzzle
{
    return @[[UIImage imageNamed:@"puzzle3.png"],[UIImage imageNamed:@"jigsaw1"]];
}

- (NSDictionary *)numberOfPiecesForPuzzle
{
    if (mode == jigSawAdultMode)
        return @{@"H":@12,@"V":@8};
    else
        return @{@"H":@3,@"V":@2};
}

- (BOOL)showHintImage
{
    if (mode == jigsawKidMode)
        return YES;
    return NO;
}

@end
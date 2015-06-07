//
//  ViewController.m
//  KiPuzzle
//
//  Created by Caio Coan on 6/3/15.
//  Copyright (c) 2015 Caio Coan. All rights reserved.
//

#import "ViewController.h"

#import "JigsawVC.h"

static NSString* const kSegueIdShowPuzzle = @"ShowPuzzleSegue";
static NSString* const kImageCellIdentifier = @"imageCell";
static NSString* const kPuzzleImagePrefix = @"PZI";
static NSString* const kPuzzleImageFormatSuffix = @".png";

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(strong,nonatomic)NSArray* imageFiles;
@property(weak,nonatomic)IBOutlet UITableView* imageTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self fillImageNames];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSIndexPath* path = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.imageTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.imageFiles count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kImageCellIdentifier];
    
    NSString* imageName = self.imageFiles[indexPath.row];
    NSString* displayName = [self displayStringFromImageName:imageName];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",displayName];
    
    return cell;
}

- (NSString*)displayStringFromImageName:(NSString*)imageName {
    NSUInteger stringLength = [imageName length];
    NSUInteger prefixLength = [kPuzzleImagePrefix length];
    NSUInteger suffixLength = [kPuzzleImageFormatSuffix length];
    NSUInteger displayLength = stringLength - prefixLength - suffixLength;
    NSRange range = NSMakeRange(prefixLength, displayLength);
    NSString* displayString = [imageName substringWithRange:range];
    displayString = [displayString capitalizedString];
    
    return displayString;
}

#pragma mark - Data

- (void)fillImageNames {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSError* error = nil;
    
    NSMutableArray* tempArray = [NSMutableArray array];
    
    NSArray* contents = [fileManager contentsOfDirectoryAtPath:bundlePath error:&error];
    if (error.code != noErr) {
        NSLog(@"Error loading bundle path: %@",[error localizedDescription]);
    } else {
        NSLog(@"Contents: %@",contents);
        for (NSString* fileString in contents) {
            NSRange prefixRange = [fileString rangeOfString:kPuzzleImagePrefix];
            NSRange suffixRange = [fileString rangeOfString:kPuzzleImageFormatSuffix];
            if (prefixRange.location != NSNotFound && suffixRange.location != NSNotFound) {
                [tempArray addObject:fileString];
            }
        }
    }
    
    self.imageFiles = [NSArray arrayWithArray:tempArray];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdShowPuzzle]) {
        NSIndexPath* path = [self.imageTableView indexPathForSelectedRow];
        
        NSString* imageString = self.imageFiles[path.row];
        JigsawVC* destination = segue.destinationViewController;
        destination.currentImage = imageString;
    }
}

@end

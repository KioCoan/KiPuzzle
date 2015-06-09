//
//  ViewController.m
//  KiPuzzle
//
//  Created by Caio Coan on 6/3/15.
//  Copyright (c) 2015 Caio Coan. All rights reserved.
//

#import "MainVC.h"

#import "ImageCell.h"
#import "HeaderView.h"
#import "JigsawVC.h"

static NSString* const kSegueIdShowPuzzle = @"ShowPuzzleSegue";
static NSString* const kImageCellIdentifier = @"imageCell";
static NSString* const kPuzzleImagePrefix = @"PZI";
static NSString* const kPuzzleImageFormatSuffix = @".png";

@interface MainVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(strong,nonatomic)NSMutableArray* imageFiles;
@property (weak, nonatomic) IBOutlet UICollectionView *puzzlesCollectionView;
@property(weak,nonatomic)IBOutlet UISlider* horizontalSlider;
@property(weak,nonatomic)IBOutlet UISlider* verticalSlider;
@property(weak,nonatomic)IBOutlet UILabel* horzontalLabel;
@property(weak,nonatomic)IBOutlet UILabel* verticalLabel;
- (IBAction)importPuzzle:(id)sender;


@end

@implementation MainVC
@synthesize imageFiles, puzzlesCollectionView, horizontalSlider, verticalLabel, horzontalLabel, verticalSlider;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self fillImageNames];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //NSIndexPath* path = [NSIndexPath indexPathForItem:0 inSection:0];
    //[self.imageTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    [self sliderMoved:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)importPuzzle:(id)sender
{
    UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
    pickerLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerLibrary.allowsEditing = NO;
    pickerLibrary.delegate = self;
    [[self navigationController] presentViewController:pickerLibrary animated:YES completion:nil];
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* newPuzzle = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize size = CGSizeMake(1024, 768);
    UIGraphicsBeginImageContext(size);
    [newPuzzle drawInRect:CGRectMake(0, 0, size.width, size.height)];
    newPuzzle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self saveToCustomPuzzlesDirectory:newPuzzle];
    //[imageFiles addObject:@{@"MediaName":@"NewPuzzle",@"Image":newPuzzle}];
    [picker dismissViewControllerAnimated:YES completion:^(void){
        [puzzlesCollectionView reloadData];
    }];
}

- (void)saveToCustomPuzzlesDirectory:(UIImage*)image
{
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* customPuzzlesDir = [docPath stringByAppendingPathComponent:@"customPuzzles"];
    NSString* puzzleName = [[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000] stringByReplacingOccurrencesOfString:@"." withString:@""];
    puzzleName = [puzzleName stringByAppendingString:[NSString stringWithFormat:kPuzzleImageFormatSuffix]];
    puzzleName = [kPuzzleImagePrefix stringByAppendingString:puzzleName];
    NSString* puzzlePath = [customPuzzlesDir stringByAppendingPathComponent:puzzleName];
    BOOL isDir = YES;
    if(![fm fileExistsAtPath:customPuzzlesDir isDirectory:&isDir])
    {
        [fm createDirectoryAtPath:customPuzzlesDir withIntermediateDirectories:nil attributes:nil error:nil];
    }
    if(![fm fileExistsAtPath:puzzlePath])
    {
        NSData* data = UIImagePNGRepresentation(image);
        if([data writeToFile:puzzlePath atomically:YES])
            NSLog(@"Puzzle Saved Locally");
        else
            NSLog(@"Failed to save puzzle");
    }
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    [self fillImageNames];
    return [imageFiles count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self imageFiles][section] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kImageCellIdentifier forIndexPath:indexPath];
    cell.image.image = imageFiles[indexPath.section][indexPath.row][@"Image"];
    [cell.image.layer setBorderColor:[UIColor blackColor].CGColor];
    [cell.image.layer setBorderWidth:2.0];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView* view = nil;
    if(kind == UICollectionElementKindSectionHeader)
    {
        HeaderView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        NSString* title = nil;
        if (indexPath.section == 0)
            title = @"Default Puzzles";
        else if(indexPath.section == 1)
            title = @"Custom Puzzles";
        else
            title = @"This shouldn't happen";
        headerView.title.text = title;
        view = headerView;
    }
    return view;
}


#pragma mark - Data

- (void)fillImageNames {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSError* error = nil;
    imageFiles = [NSMutableArray array];
    NSMutableArray* defaultImages = [NSMutableArray new];
    NSMutableArray* customPuzzles = [NSMutableArray new];
    NSArray* contents = [fileManager contentsOfDirectoryAtPath:bundlePath error:&error];
    if (error.code != noErr) {
        NSLog(@"Error loading bundle path: %@",[error localizedDescription]);
    } else {
        NSLog(@"Contents: %@",contents);
        for (NSString* fileString in contents) {
            NSRange prefixRange = [fileString rangeOfString:kPuzzleImagePrefix];
            NSRange suffixRange = [fileString rangeOfString:kPuzzleImageFormatSuffix];
            if (prefixRange.location != NSNotFound && suffixRange.location != NSNotFound) {
                [defaultImages addObject:@{@"ImageName":fileString,@"Image":[UIImage imageNamed:fileString]}];
            }
        }
    }
    NSString* customPuzzlesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    customPuzzlesPath = [customPuzzlesPath stringByAppendingPathComponent:@"customPuzzles/"];
    contents = [fileManager contentsOfDirectoryAtPath:customPuzzlesPath error:&error];
    for (NSString* fileString in contents) {
        NSRange prefixRange = [fileString rangeOfString:kPuzzleImagePrefix];
        NSRange suffixRange = [fileString rangeOfString:kPuzzleImageFormatSuffix];
        if (prefixRange.location != NSNotFound && suffixRange.location != NSNotFound) {
            UIImage* image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfFile:[customPuzzlesPath stringByAppendingPathComponent:fileString]]];
            [customPuzzles addObject:@{@"ImageName":fileString,@"Image":image}];
        }
    }
    [imageFiles addObject:defaultImages];
    [imageFiles addObject:customPuzzles];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdShowPuzzle]) {
        ImageCell* cell = (ImageCell*)sender;
        NSIndexPath* path = [puzzlesCollectionView indexPathForCell:cell];
        JigsawVC* destination = segue.destinationViewController;
        destination.currentImage = imageFiles[path.section][path.row];
        NSInteger horizontal = horizontalSlider.value;
        destination.numberHorizontal = [NSString stringWithFormat:@"%ld", horizontal];
        NSInteger vertical = verticalSlider.value;
        destination.numberVertical = [NSString stringWithFormat:@"%ld", vertical];
    }
}

#pragma mark - Actions

- (IBAction)sliderMoved:(id)sender {
    NSUInteger horizontal = self.horizontalSlider.value;
    self.horzontalLabel.text = [NSString stringWithFormat:@"H: %ld",horizontal];
    
    NSUInteger vertical = self.verticalSlider.value;
    self.verticalLabel.text = [NSString stringWithFormat:@"V: %ld",vertical];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
@end
